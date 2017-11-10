local sproto = require "sproto"
local core = require "sproto.core"
local print_r = require "print_r"

local sp = sproto.parse [[
.Person {
	name 0 : string
	id 1 : integer
	email 2 : string

	.PhoneNumber {
		number 0 : string
		type 1 : integer
	}

	phone 3 : *PhoneNumber
}

.AddressBook {
	person 0 : *Person(id)
	others 1 : *Person
}
]]

-- core.dumpproto only for debug use
print(type(sp))
print_r(sp)
print('-----------111-----dump-proto--VVV---')

core.dumpproto(sp.__cobj)

print("-------------222------AAA------")

local def = sp:default "Person"
print("default table for Person")
print_r(def)

--[[
local def = sp:default("Person", "REQUEST")
print("default table for Person.REQUEST")
print_r(def)

local def = sp:default("Person", "RESPONSE")
print("default table for Person")
print_r(def)
]]

local def = sp:default "AddressBook"
print("default table for AddressBook")
print_r(def)


--[[


local def = sp:default("foobar", "REQUEST")
print("default table for foobar.REQUEST")
print_r(def)

local def = sp:default("foobar", "RESPONSE")
print("default table for foobar.RESPONSE")
print_r(def)
]]


print("-------------333------------")

local addressBook = {
	person = {
		[10000] = {
			name = "Alice",
			id = 10000,
			phone = {
				{ number = "123456789" , type = 1 },
				{ number = "87654321" , type = 2 },
			},
			email = "zhouyanlt@qq.com",
		},
		[20000] = {
			name = "Bob",
			id = 20000,
			email = "zhouyan@qq.com",
			phone = {
				{ number = "01234567890" , type = 3 },
			}
		}
	},
	others = {
		{
			name = "Carol",
			id = 30000,
			phone = {
				{ number = "9876543210" },
			}
		},
	}
}

collectgarbage "stop"

-- 序列化： lua table ---> sproto bin
local code = sp:encode("AddressBook", addressBook)
print("-----------------------lua table ---> sproto bin----------------------\n", type(code))
print(code:byte(1, code:len()))
print(code)
-- 反序列化： sproto bin ---> lua table
local addr = sp:decode("AddressBook", code)
print_r(addr)
