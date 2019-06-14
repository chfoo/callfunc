package callfunc;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        var runner = new Runner();
        runner.addCase(new callfunc.test.TestCairoMatrix());
        runner.addCase(new callfunc.test.TestCairoSurface());
        runner.addCase(new callfunc.test.TestExamplelib());
        runner.addCase(new callfunc.test.TestMemory());
        runner.addCase(new callfunc.test.TestPointer());
        Report.create(runner);
        runner.run();
    }
}
