require 'json'
@clock = 0
MESSAGES = [
  [], [], [],
  [{name: 'ujihisa', body: 'hi'}],
  [], [],
  [{name: 'kana', body: 'hi!'}, {name: 'ujihisa', body: 'hi.'}],
  [], [],
  [{name: 'ujihisa', body: 'benri'}]]

@say_buffer = []

def rbhear()
  @clock += 1
  tmp = MESSAGES[@clock % MESSAGES.size] + @say_buffer
  @say_buffer = []
  tmp.to_json
end

def rbsay(name, body)
  @say_buffer.push({name: name, body: body})
end
