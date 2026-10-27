import CoreGraphics
import Foundation
import Testing
@testable import DinkyLayout

struct StaleFrameTests {
    @Test func newerTargetPreventsOldRetry() {
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
            writes.append(job.frame.minX)
            if job.frame.minX == 200 { actual = job.frame }
        })
        scheduler.submit([old])
        #expect(done.wait(timeout: .now() + 2) == .success)
        #expect(writes == [100, 200])
    }

    @Test func newerTargetPreventsUnwrittenJob() {
        let done = DispatchSemaphore(value: 0)
        var scheduler: FrameScheduler!
        var reads = 0
        var writes: [CGFloat] = []
        var actual = CGRect.zero
        let old = FrameJob(pid: 1, id: 1, frame: CGRect(x: 100, y: 0, width: 100, height: 100))
        let newer = FrameJob(pid: 1, id: 1, frame: CGRect(x: 200, y: 0, width: 100, height: 100))
        scheduler = FrameScheduler(settle: 0, alive: { _ in true }, read: { _ in
            reads += 1
            if reads == 1 { scheduler.submit([newer]) { _ in done.signal() } }
            return actual
        }, write: { job in writes.append(job.frame.minX); actual = job.frame })
        scheduler.submit([old])
        #expect(done.wait(timeout: .now() + 2) == .success)
        #expect(writes == [200])
    }

    @Test func preparesEachBatch() {
        var batches = 0
        var actual = CGRect.zero
        let scheduler = FrameScheduler(settle: 0, beforeBatch: { _ in batches += 1 },
            alive: { _ in true }, read: { _ in actual }, write: { actual = $0.frame })
        for x in [100, 200] {
            let done = DispatchSemaphore(value: 0)
            scheduler.submit([FrameJob(pid: 1, id: 1, frame: CGRect(x: x, y: 0, width: 100, height: 100))]) { _ in done.signal() }
            #expect(done.wait(timeout: .now() + 2) == .success)
        }
        #expect(batches == 2)
    }
}
