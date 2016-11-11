local tiny = {}

local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local setmetatable = setmetatable
local type = type
local select = select

local tiny_manageEntities
local tiny_manageSystems
local tiny_addEntity
local tiny_addSystem
local tiny_add
local tiny_removeEntity
local tiny_removeSystem

local filterJoin

local filterBuildString

do

    local loadstring = loadstring or load
    local function getchr(c)
        return "\\" .. c:byte()
    end
    local function make_safe(text)
        return ("%q"):format(text):gsub('\n', 'n'):gsub("[\128-\255]", getchr)
    end

    local function filterJoinRaw(prefix, seperator, ...)
        local accum = {}
        local build = {}
        for i = 1, select('#', ...) do
            local item = select(i, ...)
            if type(item) == 'string' then
                accum[#accum + 1] = ("(e[%s] ~= nil)"):format(make_safe(item))
            elseif type(item) == 'function' then
                build[#build + 1] = ('local subfilter_%d_ = select(%d, ...)')
                    :format(i, i)
                accum[#accum + 1] = ('(subfilter_%d_(system, e))'):format(i)
            else
                error 'Filter token must be a string or a filter function.'
            end
        end
        local source = ('%s\nreturn function(system, e) return %s(%s) end')
            :format(
                table.concat(build, '\n'),
                prefix,
                table.concat(accum, seperator))
        local loader, err = loadstring(source)
        if err then error(err) end
        return loader(...)
    end

    function filterJoin(...)
        local state, value = pcall(filterJoinRaw, ...)
        if state then return value else return nil, value end
    end

    local function buildPart(str)
        local accum = {}
        local subParts = {}
        str = str:gsub('%b()', function(p)
            subParts[#subParts + 1] = buildPart(p:sub(2, -2))
            return ('\255%d'):format(#subParts)
        end)
        for invert, part, sep in str:gmatch('(%!?)([^%|%&%!]+)([%|%&]?)') do
            if part:match('^\255%d+$') then
                local partIndex = tonumber(part:match(part:sub(2)))
                accum[#accum + 1] = ('%s(%s)')
                    :format(invert == '' and '' or 'not', subParts[partIndex])
            else
                accum[#accum + 1] = ("(e[%s] %s nil)")
                    :format(make_safe(part), invert == '' and '~=' or '==')
            end
            if sep ~= '' then
                accum[#accum + 1] = (sep == '|' and ' or ' or ' and ')
            end
        end
        return table.concat(accum)
    end

    function filterBuildString(str)
        local source = ("return function(_, e) return %s end")
            :format(buildPart(str))
        local loader, err = loadstring(source)
        if err then
            error(err)
        end
        return loader()
    end

end

function tiny.requireAll(...)
    return filterJoin('', ' and ', ...)
end

function tiny.requireAny(...)
    return filterJoin('', ' or ', ...)
end

function tiny.rejectAll(...)
    return filterJoin('not', ' and ', ...)
end

function tiny.rejectAny(...)
    return filterJoin('not', ' or ', ...)
end

function tiny.filter(pattern)
    local state, value = pcall(filterBuildString, pattern)
    if state then return value else return nil, value end
end

local systemTableKey = { "SYSTEM_TABLE_KEY" }

local function isSystem(table)
    return table[systemTableKey]
end

local function processingSystemUpdate(system, dt)
    local preProcess = system.preProcess
    local process = system.process
    local postProcess = system.postProcess

    if preProcess then
        preProcess(system, dt)
    end

    if process then
        if system.nocache then
            local entities = system.world.entityList
            local filter = system.filter
            if filter then
                for i = 1, #entities do
                    local entity = entities[i]
                    if filter(system, entity) then
                        process(system, entity, dt)
                    end
                end
            end
        else
            local entities = system.entities
            for i = 1, #entities do
                process(system, entities[i], dt)
            end
        end
    end

    if postProcess then
        postProcess(system, dt)
    end
end

local function sortedSystemOnModify(system)
    local entities = system.entities
    local indices = system.indices
    local sortDelegate = system.sortDelegate
    if not sortDelegate then
        local compare = system.compare
        sortDelegate = function(e1, e2)
            return compare(system, e1, e2)
        end
        system.sortDelegate = sortDelegate
    end
    tsort(entities, sortDelegate)
    for i = 1, #entities do
        indices[entities[i]] = i
    end
end

function tiny.system(table)
    table = table or {}
    table[systemTableKey] = true
    return table
end

function tiny.processingSystem(table)
    table = table or {}
    table[systemTableKey] = true
    table.update = processingSystemUpdate
    return table
end

function tiny.sortedSystem(table)
    table = table or {}
    table[systemTableKey] = true
    table.onModify = sortedSystemOnModify
    return table
end

function tiny.sortedProcessingSystem(table)
    table = table or {}
    table[systemTableKey] = true
    table.update = processingSystemUpdate
    table.onModify = sortedSystemOnModify
    return table
end

local worldMetaTable

function tiny.world(...)
    local ret = setmetatable({

        entitiesToRemove = {},

        entitiesToChange = {},

        systemsToAdd = {},

        systemsToRemove = {},

        entities = {},

        systems = {}

    }, worldMetaTable)

    tiny_add(ret, ...)
    tiny_manageSystems(ret)
    tiny_manageEntities(ret)

    return ret, ...
end

function tiny.addEntity(world, entity)
    local e2c = world.entitiesToChange
    e2c[#e2c + 1] = entity
    return entity
end
tiny_addEntity = tiny.addEntity

function tiny.addSystem(world, system)
    assert(system.world == nil, "System already belongs to a World.")
    local s2a = world.systemsToAdd
    s2a[#s2a + 1] = system
    system.world = world
    return system
end
tiny_addSystem = tiny.addSystem

function tiny.add(world, ...)
    for i = 1, select("#", ...) do
        local obj = select(i, ...)
        if obj then
            if isSystem(obj) then
                tiny_addSystem(world, obj)
            else
                tiny_addEntity(world, obj)
            end
        end
    end
    return ...
end
tiny_add = tiny.add

function tiny.removeEntity(world, entity)
    local e2r = world.entitiesToRemove
    e2r[#e2r + 1] = entity
    return entity
end
tiny_removeEntity = tiny.removeEntity

function tiny.removeSystem(world, system)
    assert(system.world == world, "System does not belong to this World.")
    local s2r = world.systemsToRemove
    s2r[#s2r + 1] = system
    return system
end
tiny_removeSystem = tiny.removeSystem

function tiny.remove(world, ...)
    for i = 1, select("#", ...) do
        local obj = select(i, ...)
        if obj then
            if isSystem(obj) then
                tiny_removeSystem(world, obj)
            else
                tiny_removeEntity(world, obj)
            end
        end
    end
    return ...
end

function tiny_manageSystems(world)
    local s2a, s2r = world.systemsToAdd, world.systemsToRemove

    if #s2a == 0 and #s2r == 0 then
        return
    end

    world.systemsToAdd = {}
    world.systemsToRemove = {}

    local worldEntityList = world.entities
    local systems = world.systems

    for i = 1, #s2r do
        local system = s2r[i]
        local index = system.index
        local onRemove = system.onRemove
        if onRemove and not system.nocache then
            local entityList = system.entities
            for j = 1, #entityList do
                onRemove(system, entityList[j])
            end
        end
        tremove(systems, index)
        for j = index, #systems do
            systems[j].index = j
        end
        local onRemoveFromWorld = system.onRemoveFromWorld
        if onRemoveFromWorld then
            onRemoveFromWorld(system, world)
        end
        s2r[i] = nil

        system.world = nil
        system.entities = nil
        system.indices = nil
        system.index = nil
    end

    for i = 1, #s2a do
        local system = s2a[i]
        if systems[system.index or 0] ~= system then
            if not system.nocache then
                system.entities = {}
                system.indices = {}
            end
            if system.active == nil then
                system.active = true
            end
            system.modified = true
            system.world = world
            local index = #systems + 1
            system.index = index
            systems[index] = system
            local onAddToWorld = system.onAddToWorld
            if onAddToWorld then
                onAddToWorld(system, world)
            end

            if not system.nocache then
                local entityList = system.entities
                local entityIndices = system.indices
                local onAdd = system.onAdd
                local filter = system.filter
                if filter then
                    for j = 1, #worldEntityList do
                        local entity = worldEntityList[j]
                        if filter(system, entity) then
                            local entityIndex = #entityList + 1
                            entityList[entityIndex] = entity
                            entityIndices[entity] = entityIndex
                            if onAdd then
                                onAdd(system, entity)
                            end
                        end
                    end
                end
            end
        end
        s2a[i] = nil
    end
end

function tiny_manageEntities(world)

    local e2r = world.entitiesToRemove
    local e2c = world.entitiesToChange

    if #e2r == 0 and #e2c == 0 then
        return
    end

    world.entitiesToChange = {}
    world.entitiesToRemove = {}

    local entities = world.entities
    local systems = world.systems

    for i = 1, #e2c do
        local entity = e2c[i]

        if not entities[entity] then
            local index = #entities + 1
            entities[entity] = index
            entities[index] = entity
        end
        for j = 1, #systems do
            local system = systems[j]
            if not system.nocache then
                local ses = system.entities
                local seis = system.indices
                local index = seis[entity]
                local filter = system.filter
                if filter and filter(system, entity) then
                    if not index then
                        system.modified = true
                        index = #ses + 1
                        ses[index] = entity
                        seis[entity] = index
                        local onAdd = system.onAdd
                        if onAdd then
                            onAdd(system, entity)
                        end
                    end
                elseif index then
                    system.modified = true
                    local tmpEntity = ses[#ses]
                    ses[index] = tmpEntity
                    seis[tmpEntity] = index
                    seis[entity] = nil
                    ses[#ses] = nil
                    local onRemove = system.onRemove
                    if onRemove then
                        onRemove(system, entity)
                    end
                end
            end
        end
        e2c[i] = nil
    end

    for i = 1, #e2r do
        local entity = e2r[i]
        e2r[i] = nil
        local listIndex = entities[entity]
        if listIndex then

            local lastEntity = entities[#entities]
            entities[lastEntity] = listIndex
            entities[entity] = nil
            entities[listIndex] = lastEntity
            entities[#entities] = nil

            for j = 1, #systems do
                local system = systems[j]
                if not system.nocache then
                    local ses = system.entities
                    local seis = system.indices
                    local index = seis[entity]
                    if index then
                        system.modified = true
                        local tmpEntity = ses[#ses]
                        ses[index] = tmpEntity
                        seis[tmpEntity] = index
                        seis[entity] = nil
                        ses[#ses] = nil
                        local onRemove = system.onRemove
                        if onRemove then
                            onRemove(system, entity)
                        end
                    end
                end
            end
        end
    end
end

function tiny.refresh(world)
    tiny_manageSystems(world)
    tiny_manageEntities(world)
    local systems = world.systems
    for i = #systems, 1, -1 do
        local system = systems[i]
        if system.active then
            local onModify = system.onModify
            if onModify and system.modified then
                onModify(system, 0)
            end
            system.modified = false
        end
    end
end

function tiny.update(world, dt, filter)

    tiny_manageSystems(world)
    tiny_manageEntities(world)

    local systems = world.systems

    for i = #systems, 1, -1 do
        local system = systems[i]
        if system.active then

            local onModify = system.onModify
            if onModify and system.modified then
                onModify(system, dt)
            end
            local preWrap = system.preWrap
            if preWrap and
                ((not filter) or filter(world, system)) then
                preWrap(system, dt)
            end
        end
    end

    for i = 1, #systems do
        local system = systems[i]
        if system.active and ((not filter) or filter(world, system)) then

            local update = system.update
            if update then
                local interval = system.interval
                if interval then
                    local bufferedTime = (system.bufferedTime or 0) + dt
                    while bufferedTime >= interval do
                        bufferedTime = bufferedTime - interval
                        update(system, interval)
                    end
                    system.bufferedTime = bufferedTime
                else
                    update(system, dt)
                end
            end

            system.modified = false
        end
    end

    for i = 1, #systems do
        local system = systems[i]
        local postWrap = system.postWrap
        if postWrap and system.active and
            ((not filter) or filter(world, system)) then
            postWrap(system, dt)
        end
    end

end

function tiny.clearEntities(world)
    local el = world.entities
    for i = 1, #el do
        tiny_removeEntity(world, el[i])
    end
end

function tiny.clearSystems(world)
    local systems = world.systems
    for i = #systems, 1, -1 do
        tiny_removeSystem(world, systems[i])
    end
end

function tiny.getEntityCount(world)
    return #world.entities
end

function tiny.getSystemCount(world)
    return #world.systems
end

function tiny.setSystemIndex(world, system, index)
    local oldIndex = system.index
    local systems = world.systems

    if index < 0 then
        index = tiny.getSystemCount(world) + 1 + index
    end

    tremove(systems, oldIndex)
    tinsert(systems, index, system)

    for i = oldIndex, index, index >= oldIndex and 1 or -1 do
        systems[i].index = i
    end

    return oldIndex
end

worldMetaTable = {
    __index = {
        add = tiny.add,
        addEntity = tiny.addEntity,
        addSystem = tiny.addSystem,
        remove = tiny.remove,
        removeEntity = tiny.removeEntity,
        removeSystem = tiny.removeSystem,
        refresh = tiny.refresh,
        update = tiny.update,
        clearEntities = tiny.clearEntities,
        clearSystems = tiny.clearSystems,
        getEntityCount = tiny.getEntityCount,
        getSystemCount = tiny.getSystemCount,
        setSystemIndex = tiny.setSystemIndex
    },
    __tostring = function()
        return "<tiny-ecs_World>"
    end
}

return tiny
