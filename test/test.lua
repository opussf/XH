#!/usr/bin/env lua

addonData = { ["version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

-- Figure out how to parse the XML here, until then....

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "XH_data"
require "XH"

function test.test_noop()
end

test.run()