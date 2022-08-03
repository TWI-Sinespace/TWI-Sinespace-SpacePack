using System.CodeDom.Compiler;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.CSharp;
using UnityEditor;

public static class PrepareEditorPack
{
    const string outputDir = @"C:\Users\Adam\Projects\gojiyo_v2\trunk\editor-pack\sinewave.Space Distributable Pack\Assets\SpacePack";


#if !SPACE_DLL
    //[MenuItem("Tools/Prepare Editor Pack")]
    public static void PrepareEditor()
    {
        Regex csFileOK = new Regex("^.*(class).*:.*(BaseInternal).*$");
        var csFiles = Directory.GetFiles("Assets", "*.cs", SearchOption.AllDirectories);

        CompilerParameters parameters = new CompilerParameters();
        parameters.GenerateExecutable = false;
        parameters.OutputAssembly = Path.Combine(outputDir, "SpaceCore.dll");
        CSharpCodeProvider compiler = new CSharpCodeProvider();

        List<string> compiledCS = new List<string>(5000);
        List<string> copyCS = new List<string>(5000);
        List<string> editorCS = new List<string>();

        foreach (var csFile in csFiles)
        {
            if (csFile.Contains("\\Editor\\")) // Editor script
            {
                editorCS.Add(csFile);
                continue;
            }

            var lines = File.ReadAllLines(csFile);
            if (lines.Any(line => csFileOK.IsMatch(line)))
            {
                // Add to copy list.
                copyCS.Add(csFile);
            }
            else
            {
                // Add to DLL list
                compiledCS.Add(csFile);
            }
        }

        List<string> dlls = new List<string>();
        var dllFiles = Directory.GetFiles("Assets", "*.dll", SearchOption.AllDirectories);
        foreach (var dllFile in dllFiles)
        {
            if (!dllFile.Contains("\\Editor\\"))
            {
                dlls.Add(dllFile);
            }
        }

        string[] defines =
        {
            "UNITY_5_3_OR_NEWER",
            "UNITY_5_3_4",
            "UNITY_5_3",
            "UNITY_5",

            "UNITY_STANDALONE",
            "SPACE_PIPELINE",
            "SPACE_DLL"
        };
        
        string[] builtInReferences =
        {
            @"C:/Program Files/Unity5/Editor/Data/Managed/UnityEngine.dll",
            @"Library/ScriptAssemblies/Assembly-CSharp-firstpass.dll",
            @"Library/ScriptAssemblies/Assembly-CSharp.dll",
            @"C:/Program Files/Unity5/Editor/Data/UnityExtensions/Unity/GUISystem/UnityEngine.UI.dll",
            @"C:/Program Files/Unity5/Editor/Data/UnityExtensions/Unity/Networking/UnityEngine.Networking.dll",
            @"C:/Program Files/Unity5/Editor/Data/Managed/UnityEditor.dll",
            @"C:/Program Files/Unity5/Editor/Data\Managed/Mono.Cecil.dll",
            @"C:\Program Files\Unity5\Editor\Data\PlaybackEngines\AppleTVSupport\UnityEditor.iOS.Extensions.Xcode.dll",
            @"C:\Program Files\Unity5\Editor\Data\PlaybackEngines\AppleTVSupport\UnityEditor.iOS.Extensions.Common.dll",
            @"C:/Program Files/Unity5/Editor/Data/PlaybackEngines/iOSSupport\UnityEditor.iOS.Extensions.Xcode.dll",
            @"C:/Program Files/Unity5/Editor/Data/PlaybackEngines/iOSSupport\UnityEditor.iOS.Extensions.Common.dll",
        };
        
        parameters.CompilerOptions = "/define:" + string.Join(";",defines);
        parameters.ReferencedAssemblies.AddRange(builtInReferences);
        parameters.ReferencedAssemblies.AddRange(dlls.ToArray());

        var results = compiler.CompileAssemblyFromFile(parameters, compiledCS.ToArray());
        if (results.Errors.HasErrors)
        {
            List<string> errors = new List<string>();
            for (int i = 0; i < results.Errors.Count; i++)
            {
                var error = results.Errors[i];

                if (!error.IsWarning)
                    errors.Add(error.FileName + ":" + error.Line + "," + error.Column + " [" + error.ErrorNumber + "] " + error.ErrorText);
            }
            File.WriteAllLines(Path.Combine(outputDir, "Errors.txt"), errors.ToArray());
        }
    }
#endif
}
