import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class ScriptRunner extends StatefulWidget {
  const ScriptRunner({super.key});

  @override
  State<ScriptRunner> createState() => _ScriptRunnerState();
}

class _ScriptRunnerState extends State<ScriptRunner> {
  String _output = '';

  Future<void> _runPythonScript() async {
    setState(() {
      _output = 'Running script...';
    });

    try {
      // Get the application directory (one level up from lib folder)
      final String appDir = p.dirname(p.dirname(Platform.script.toFilePath()));
      final scriptPath = p.join(appDir, 'python_scripts', 'mocap.py');
      
      // Print the path for debugging
      print('Attempting to run Python script at: $scriptPath');
      
      // Check if the script exists
      if (!File(scriptPath).existsSync()) {
        setState(() {
          _output = 'Error: Script not found at $scriptPath';
        });
        return;
      }
      
      // Use ProcessResult to run python (use 'python' for Windows instead of 'python3')
      final pythonExecutable = Platform.isWindows ? 'python' : 'python3';
      
      // Set the working directory to the python_scripts folder for relative imports
      final workingDir = p.join(appDir, 'python_scripts');
      final result = await Process.run(
        pythonExecutable, 
        [scriptPath],
        workingDirectory: workingDir,
      );

      setState(() {
        _output = result.stdout.toString().trim();
        if (_output.isEmpty && result.stderr.toString().isNotEmpty) {
          _output = 'Error: ${result.stderr}';
        }
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _runPythonScript,
          child: const Text('Run Python Script'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              _output,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
