local sproto = require "sproto"
local core = require "sproto.core"
local print_r = require "print_r"

local server_proto = sproto.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

foobar 1 {
	request {
		what 0 : string
	}
	response {
		ok 0 : boolean
	}
}

foo 2 {
	response {
		ok 0 : boolean
	}
}

bar 3 {
	response nil
}

blackhole 4 {
}
]]

local client_proto = sproto.parse [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

print_r(server_proto)
core.dumpproto(server_proto.__cobj)

print_r(client_proto)
core.dumpproto(client_proto.__cobj)

print("\n\n-------------------11111--------------------------")

print(server_proto:exist_type "package")
print(server_proto:exist_proto "foobar")
print(server_proto:exist_proto "zhouyan")

print("\n\n================= default table=================")

print_r(server_proto:default("package"))
print_r(server_proto:default("foobar", "REQUEST"))
print_r(server_proto:default("foobar.request"))

assert(server_proto:default("foo", "REQUEST")==nil)

print("\n\n================= encode =================")
local foo_request_encode = server_proto:request_encode("foo")
print('request_encode("foo")', type(foo_request_encode), foo_request_encode:len(), tostring(foo_request_encode)) -- == ""

local foo_response_encode = server_proto:response_encode("foo", { ok = true })
print('response_encode("foo", { ok = true })', type(foo_response_encode), foo_response_encode:len(), tostring(foo_response_encode))
print( foo_response_encode:byte(1, foo_response_encode:len()) )

print("\n\n================= decode =================")
local blackhole_req_decode = server_proto:request_decode("blackhole")
print(type(blackhole_req_decode), tostring(blackhole_req_decode), blackhole_req_decode) -- nil

local blackhole_res_decode = server_proto:response_decode("blackhole")
print(type(blackhole_res_decode), tostring(blackhole_res_decode), blackhole_res_decode) -- nil

print("\n\n====================================== test 1")

-- The type package must has two field : type and session
local server = server_proto:host "package"
local client = client_proto:host "package"
print_r(server)
print_r(client)

local client_request = client:attach(server_proto)

print("\n\n第一次通讯， session = 1")
print("client request foobar")
local req = client_request("foobar", { what = "foo" }, 1)
-- CS程序内，req 要发给服务端
print("request foobar size =", #req)
print(type(req), req:byte(1, req:len()))
print("---------111-----------")

print("服务端收到客户端请求的 req 后开始处理：")
local proto_type, name, request, response = server:dispatch(req)
print(proto_type, name, request, response)
assert(proto_type == "REQUEST" and name == "foobar")
print_r(request)
print("\n----------222----------")

print("服务端返回 resp")
print("server response")
local resp = response { ok = true }
print("response package size =", #resp)
print(type(resp)) -- string, CS程序内，resp 要发给客户端
print(resp:byte(1, resp:len()))

print("客户端收到服务端返回的 resp 后开始处理：")
print("client dispatch")
local proto_type, session, response = client:dispatch(resp)
assert(proto_type == "RESPONSE" and session == 1)
print_r(response) -- string


print("\n\n第二次通讯， session = 2")
local req = client_request("foo", nil, 2)
print("request foo size =", #req)
local _type, name, request, response = server:dispatch(req)
assert(_type == "REQUEST" and name == "foo" and request == nil)
local resp = response { ok = false }
print("response package size =", #resp)
print("client dispatch")
local _type, session, response = client:dispatch(resp)
assert(_type == "RESPONSE" and session == 2)
print_r(response)

print("\n\n第三次通讯， session = 3")
local req = client_request("bar", nil, 3)
print("request bar size =", #req)
local _type, name, request, response = server:dispatch(req)
assert(_type == "REQUEST" and name == "bar" and request == nil)
local resp = response()
print(type(resp), resp:len(), resp:byte(1, resp:len()))
local _type, session, response = client:dispatch(resp)
print(_type, session, response)

-- 这里相当于 assert(session == 3)
--assert(select(2,client:dispatch(response())) == 3)

print("\n\n==========blackhole============")
local req = client_request "blackhole"	-- no response
print(req, req:byte(1, req:len()))
print("request blackhole size = ", #req)

print("\n\n======================= test 2")
local v, tag = server_proto:request_encode("foobar", { what = "hello"})
assert(tag == 1)	-- foobar : 1
print("tag =", tag)
print_r(server_proto:request_decode("foobar", v))
local v = server_proto:response_encode("foobar", { ok = true })
print_r(server_proto:response_decode("foobar", v))
