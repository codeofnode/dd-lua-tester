Account = {}
Account.__index = Account

function Account:create(balance)
   local acnt = {}             -- our new object
   setmetatable(acnt,Account)  -- make Account handle lookup
   acnt.balance = balance      -- initialize our object
   return acnt
end

function Account:debit(amount)
   self.balance = self.balance - amount
end

function Account:credit(amount)
   self.balance = self.balance + amount
end

function Account:getBalance()
   return self.balance
end
