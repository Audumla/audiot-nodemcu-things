local EmptyThing = {}

function EmptyThing:standUp() 
    self:stoodUp()
end

function EmptyThing:standDown() 
    self:stoodDown()
end

return EmptyThing
