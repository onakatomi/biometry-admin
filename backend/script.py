import ollama, time

counter = 0

while True:
  response = ollama.generate(model='gemma3', prompt=f'Tell me about the number {counter}.')
  print(response['response'])
  time.sleep(3)
  counter += 1