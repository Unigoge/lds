--[[
lds - LuaJIT Data Structures

Copyright (c) 2012 Evan Wies.  All righs reserved.
See the COPYRIGHT file for licensing.

Array

Note that this implementation does *not* use the FFI VLA.

TODO: bounds check (return nil or error?)
TODO: allocator
TODO: iterator
TODO: full __index and __newindex?

--]]

local lds = require 'lds/init'

local ffi = require 'ffi'
local C = ffi.C


local ArrayT_cdef = [[
struct {
    $ *a;
    int n_max;
}
]]


local ArrayT_mt = {

    __new = function( at_ct, ct_size, n_max )
        return ffi.new( at_ct, {
            a = C.malloc( n_max * ct_size ),
            n_max = n_max,
        })
    end,

    __gc = function( self )
        C.free( self.a )
    end,

    __len = function( self )
        return self.n_max
    end,

    __index = {

        size = function( self )
            return self.n_max
        end,

        empty = function( self )
            return self.n_max == 0
        end,

        get = function( self, i )
            lds.assert( i >= 0 and i < self.n_max, "get: index out of bounds" )
            return self.a[i]
        end,

        set = function( self, i, x )
            lds.assert( i >= 0 and i < self.n_max, "set: index out of bounds" )
            local y = self.a[i]
            self.a[i] = x
            return y
        end,
    },
}


function lds.ArrayT( ct )
    if type(ct) ~= 'cdata' then error("argument 1 is not a valid 'cdata'") end

    local at = ffi.typeof( ArrayT_cdef, ct )
    local at_m = ffi.metatype( at, ArrayT_mt )
    return function( n_max )
        return at_m( ffi.sizeof(ct), n_max )
    end
end


function lds.Array( ct, n_max )
    return lds.ArrayT( ct )( n_max )
end


-- Return the lds API
return lds
