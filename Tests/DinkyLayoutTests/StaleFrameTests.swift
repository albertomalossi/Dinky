import CoreGraphics
import Foundation
import Testing
@testable import DinkyLayout

struct StaleFrameTests {
    @Test func newerTargetPreventsOldRetry() {
        let lock = NSLock()
        let done = DispatchSemaphore(value: 0)
        var scheduler: FrameScheduler!
        var reads = 0
        var writes: [CGFloat] = []
        var actual = CGRect.zero
        let old = FrameJob(pid: 1, id: 1, frame: CGRect(x: 100, y: 0, width: 100, height: 100))
        let newer = FrameJob(pid: 1, id: 1, frame: CGRect(x: 200, y: 0, width: 100, height: 100))
        scheduler = FrameScheduler(settle: 0, alive: { _ in true }, read: { _ in
            reads += 1
            if reads == 2 { scheduler.submit([newer]) { _ in done.signal() } }
            return actual
        }, write: { job in
            lock.withLock { writes.append(job.frame.minX) }
            if job.frame.minX == 200 { actual = job.frame }
        })
        scheduler.submit([old])
        #expect(done.wait(timeout: .now() + 2) == .success)
        #expect(lock.withLock { writes } == [100, 200])
    }

    @Test func finalFrameDropsQueuedAnimationStep() {
        let lock = NSLock()
        let prepared = DispatchSemaphore(value: 0), release = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)
        var writes: [CGFloat] = []
        var actual = CGRect.zero
        let scheduler = FrameScheduler(settle: 0, prepare: { _ in
            prepared.signal(); release.wait()
        }, alive: { _ in true }, read: { _ in actual }, write: { job in
            lock.withLock { writes.append(job.frame.minX) }; actual = job.frame
        })
        func job(_ x: CGFloat) -> FrameJob {
            FrameJob(pid: 1, id: 1, frame: CGRect(x: x, y: 0, width: 100, height: 100))
        }
        scheduler.step([job(10)])
        #expect(prepared.wait(timeout: .now() + 2) == .success)
        scheduler.step([job(20)])
        scheduler.submit([job(100)]) { _ in done.signal() }
        release.signal()
        #expect(done.wait(timeout: .now() + 2) == .success)
        #expect(lock.withLock { writes } == [100])
    }
    @Test func batchPreparationRefreshesBeforeEachWritePass() {
        var events: [String] = []
        var actual = CGRect.zero
        let scheduler = FrameScheduler(settle: 0,
            prepare: { _ in events.append("prepare") },
            beforeBatch: { _ in events.append("batch") },
            alive: { _ in true }, read: { _ in actual }, write: { job in
                events.append("write"); actual = job.frame
            })
        func submit(_ x: CGFloat) {
            let done = DispatchSemaphore(value: 0)
            scheduler.submit([FrameJob(pid: 1, id: 1, frame: CGRect(x: x, y: 0, width: 100, height: 100))]) { _ in done.signal() }
            #expect(done.wait(timeout: .now() + 2) == .success)
        }
        submit(100)
        submit(200)
        #expect(events == ["prepare", "batch", "write", "batch", "write"])
    }

}
