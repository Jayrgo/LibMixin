local _NAME = "LibMixin"
local _VERSION = "1.0.0"
local _LICENSE = [[
    MIT License

    Copyright (c) 2020 Jayrgo

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

assert(LibMan1, format("%s requires LibMan-1.x.x.", _NAME))

local lib, oldVersion = LibMan1:New(_NAME, _VERSION, "_LICENSE", _LICENSE)
if not lib then return end

local error = error
local format = format
local pairs = pairs
local select = select
local tostring = tostring
local type = type
local unpack = unpack

---@param object table
---@vararg table
---@return table
function lib:Mixin(object, ...)
    if type(object) ~= "table" then
        error(format("Usage: %s:Mixin(object[, ...]): 'object' - table expected got %s", tostring(lib), type(object)), 2)
    end
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do object[k] = v end
        if type(mixin._mixins) == "table" then self:Mixin(object, unpack(mixin._mixins)) end
        if mixin.OnLoad then mixin.OnLoad(object) end
    end
    object._mixins = nil
    return object
end

---@vararg table
---@return table
function lib:CreateFrom(...) return self:Mixin({}, ...) end

--[[ local safecall = lib.safecall ]]
local xsafecall = lib.xsafecall
local CreateFrame = CreateFrame

---@param frameType string
---@param name string
---@param parent table
---@param template string
---@param id number
---@vararg table
---@return table
function lib:CreateFrame(frameType, name, parent, template, id, ...)
    local success, result = xsafecall(CreateFrame, frameType, name, parent, template, id)
    if success then return self:Mixin(result, ...) end
end
