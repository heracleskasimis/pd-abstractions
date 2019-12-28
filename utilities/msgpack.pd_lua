local MsgPack = pd.Class:new():register("msgpack")

function MsgPack:initialize(name, atoms)
  self.senders = {}
  self.receivers = {}
  self.args = {}
  self.receives = {}

  if #atoms % 2 ~= 0 then
    pd.post("invalid number of arguments: " .. #atoms)
    return false
  end

  for i = 1, #atoms, 2 do
    self.senders[#self.senders + 1] = atoms[i] .. "-s"
    self.receivers[#self.receivers + 1] = atoms[i] .. "-r"
    self.args[#self.args + 1] = atoms[i + 1]
  end
  self.inlets = 1
  self.outlets = 1

  return true
end

function MsgPack:in_1_bang()
  for i = 1, #self.receivers, 1 do
    pd.send(self.receivers[i], "float", {self.args[i]})
  end
end

function MsgPack:postinitialize()
  for i = 1, #self.senders, 1 do
    self.receives[i] = pd.Receive:new():register(self, self.senders[i], "receive_" .. i)
    self["receive_" .. i] = function (self, sel, atoms)
      self.args[i] = atoms[1]
      self:outlet(1, "list", self.args)
    end
  end
end

function MsgPack:finalize()
  for _,r in ipairs(self.receives) do r:destruct() end
end
