from java.io import BufferedReader, InputStreamReader
from java.lang import Runtime


def run_command(args_list):
    output = ""
    error = ""
    p = Runtime.getRuntime().exec(args_list)
    i = p.waitFor()
    stdOutput = BufferedReader(InputStreamReader(p.getInputStream()))
    returnedValues = stdOutput.readLine()
    while returnedValues != None:
        output += returnedValues + "\n"
        returnedValues = stdOutput.readLine()
    stdError = BufferedReader(InputStreamReader(p.getErrorStream()))
    returnedValues = stdError.readLine()
    while returnedValues != None:
        error += returnedValues + "\n"
        returnedValues = stdError.readLine()
    return (i, output, error)
