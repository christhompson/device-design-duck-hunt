//

class CommandResult {
    public int i;
    public String output;
    public String error;

    CommandResult(int i, String output, String error) {
        this.i = i;
        this.output = new String(output);
        this.error = new String(error);
    }
}

CommandResult run_command(String[] args_list) {
    String output = "";
    String error = "";
    int i = -1;
    try {
      Process p = exec(args_list);
      i = p.waitFor();
      BufferedReader stdOutput = new BufferedReader(new InputStreamReader(p.getInputStream()));
      String returnedValues = stdOutput.readLine();
      while (returnedValues != null) {
          output = output + returnedValues + "\n";
          returnedValues = stdOutput.readLine();
      }
      BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
      returnedValues = stdError.readLine();
      while (returnedValues != null) {
          error = error + returnedValues + "\n";
          returnedValues = stdError.readLine();
      }
    } catch(Exception e) {
      println("Error reading NFC.");
      System.exit(-1);
    }
    return new CommandResult(i, output, error);
}
