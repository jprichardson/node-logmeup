{spawn} = require('child_process')
testutil = require('testutil')

task 'build', 'build lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    process.stdout.write data.toString()
  coffee.on 'exit', (code) ->
    if code is 0 
      console.log 'Successfully built.'
    else
      console.log "Error building. Code: #{code}"

task 'test', 'test project', (options) ->
  testutil.fetchTestFiles './test', (files) ->
    files.unshift '--colors'
    mocha = spawn 'mocha', files#, customFds: [0..2]
    mocha.stdout.pipe(process.stdout, { end: false });
    mocha.stderr.pipe(process.stderr, {end: false});

task 'watch', 'Watch src/ for changes', ->
    coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
    coffee.stderr.on 'data', (data) -> process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) -> process.stdout.write data.toString()