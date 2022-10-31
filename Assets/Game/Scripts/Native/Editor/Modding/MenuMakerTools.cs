﻿using System.IO;
using UnityEditor;
using Ballance2.Config.Settings;
using Ballance2.Res;
using Ballance2.Utils;
using UnityEngine;
using Ballance2.Editor.Lua;
using System.Collections.Generic;

namespace Ballance2.Editor.Modding
{
  class MenuMakerTools
  {
    [@MenuItem("Ballance/工具/复制Debug文件夹到预设输出目录", false, 103)]
    static void CopyDebugFolderToOutput()
    {
      WindowChoosePlatform choosePlatformWindow = EditorWindow.GetWindowWithRect<WindowChoosePlatform>(new Rect(200, 150, 450, 250));
      choosePlatformWindow.OnChoose = (target) =>
      {
        Debug.Log("OnChoose: " + target);

        string debugFolder = DebugSettings.Instance.DebugFolder + "/" + target;

        if (target == BuildTarget.StandaloneWindows || target == BuildTarget.StandaloneWindows64)
        {
          //Windows 直接复制到输出目录
          string folder = DebugSettings.Instance.OutputFolder;
          if (Directory.Exists(debugFolder) && Directory.Exists(folder))
          {
            CopyDebugFolder("Core", debugFolder, folder);
            CopyDebugFolder("Packages", debugFolder, folder);
            CopyDebugFolder("Levels", debugFolder, folder);

            EditorUtility.DisplayDialog("提示", "复制成功", "确定");
          }
          else EditorUtility.DisplayDialog("错误", "Output文件夹不存在：\n" + debugFolder + "\n▼\n" + folder, "确定");
        }
        else if (target == BuildTarget.StandaloneOSX)
        {
          //Mac 直接复制到输出目录
          string folder = DebugSettings.Instance.OutputAppMac + "/Contents/";
          if (Directory.Exists(debugFolder) && Directory.Exists(folder))
          {
            CopyDebugFolder("Core", debugFolder, folder);
            CopyDebugFolder("Packages", debugFolder, folder);
            CopyDebugFolder("Levels", debugFolder, folder);

            EditorUtility.DisplayDialog("提示", "复制成功", "确定");
          }
          else EditorUtility.DisplayDialog("错误", "Output文件夹不存在：\n" + debugFolder + "\n▼\n" + folder, "确定");
        }
        else if (target == BuildTarget.Android || target == BuildTarget.iOS || target == BuildTarget.WSAPlayer || target == BuildTarget.Switch)
        {
          //IOS/Android 则复制到 StreamAssets
          string folder = "Assets/StreamingAssets/BuiltInPackages";
          if (Directory.Exists(debugFolder))
          {
            if(!Directory.Exists(folder))
              Directory.CreateDirectory(folder);

            CopyDebugFolder("Core", debugFolder, folder);
            CopyDebugFolder("Packages", debugFolder, folder);
            CopyDebugFolder("Levels", debugFolder, folder);

            EditorUtility.DisplayDialog("提示", "复制成功", "确定");
          }
          else EditorUtility.DisplayDialog("错误", "debugFolder 文件夹不存在：\n" + debugFolder + "\n▼\n" + folder, "确定");
        }
        else
        {
          EditorUtility.DisplayDialog("错误", "暂不支持此平台", "确定");
        }
      };
      choosePlatformWindow.Show();
    }
    [@MenuItem("Ballance/工具/复制Debug文件夹到自定义目录", false, 103)]
    static void CopyDebugFolder()
    {
      WindowChoosePlatform choosePlatformWindow = EditorWindow.GetWindowWithRect<WindowChoosePlatform>(new Rect(200, 150, 450, 250));
      choosePlatformWindow.OnChoose = (target) =>
      {
        string debugFolder = DebugSettings.Instance.DebugFolder + "/";
        string folder = EditorUtility.OpenFolderPanel("选择输出目录", EditorPrefs.GetString("CopyDebugFolderDefSaveDir", GamePathManager.DEBUG_PATH), "");
        if (string.IsNullOrEmpty(folder))
          return;
        if (Directory.Exists(folder) && Directory.Exists(folder))
        {
          if (folder != GamePathManager.DEBUG_PATH)
            EditorPrefs.SetString("CopyDebugFolderDefSaveDir", GamePathManager.DEBUG_PATH);

          CopyDebugFolder("Core", debugFolder, folder);
          CopyDebugFolder("Packages", debugFolder, folder);
          CopyDebugFolder("Levels", debugFolder, folder);

          EditorUtility.DisplayDialog("提示", "复制成功", "确定");
        }
        else EditorUtility.DisplayDialog("错误", "文件夹不存在：\n" + debugFolder + "\n▼\n" + folder, "确定");
      };
      choosePlatformWindow.Show();
    }

    [@MenuItem("Ballance/工具/清空 BuiltInPackages 目录", false, 103)]
    public static void DeleteBuiltInPackages() {
      Directory.Delete("Assets/StreamingAssets/BuiltInPackages", true);
      EditorUtility.DisplayDialog("提示", "清空成功", "确定");
    }
    [@MenuItem("Ballance/工具/清空 SystemScrips 目录", false, 104)]
    public static void DeleteSystemScrips() {
      Directory.Delete("Assets/System/Resources/SystemScrips", true);
      Directory.CreateDirectory("Assets/System/Resources/SystemScrips");
      File.Create("Assets/System/Resources/SystemScrips/.gitkeep");
      EditorUtility.DisplayDialog("提示", "清空成功", "确定");
    }
    [@MenuItem("Ballance/工具/复制系统脚本到 Reources SystemScrips 目录", false, 104)]
    public static void CopyScriptToReourcesFolder() {
      const string folderSrc = "Assets/System/Scripts/SystemScrips";
      const string folderTarget = "Assets/System/Resources/SystemScrips";
      int count = 0;
      EditorUtility.DisplayProgressBar("正在复制", "请稍后", 0);

      Dictionary<string, string> sEditorLuaPath = new Dictionary<string, string>();
      DirectoryInfo direction = new DirectoryInfo(folderSrc);
      FileInfo[] files = direction.GetFiles("*.lua", SearchOption.AllDirectories);
      for (int i = 0; i < files.Length; i++)
      {
        var rel = StringUtils.RemoveStringByStringStart(files[i].FullName.Replace('\\', '/'), folderSrc);
        var src = folderSrc + "/" + rel;
        var dest = folderTarget + "/" + rel;
        var dir = Path.GetDirectoryName(dest);
        if (!Directory.Exists(dir))
          Directory.CreateDirectory(dir);

        var fileName = Path.GetFileName(rel);
        var fileNameNoExt = Path.GetFileNameWithoutExtension(rel);
        if (!sEditorLuaPath.ContainsKey(fileName))
          sEditorLuaPath.Add(fileName, "SystemScrips" + rel);
        if (!sEditorLuaPath.ContainsKey(fileNameNoExt))
          sEditorLuaPath.Add(fileNameNoExt, "SystemScrips" + rel);

        File.Copy(src, dest, true);
        EditorUtility.DisplayProgressBar("正在复制", rel, count / (float)files.Length);
        count++;
      }
      EditorUtility.ClearProgressBar();

      StreamWriter sw = new StreamWriter("Assets/System/Scripts/Package/EditorInfo/GameSystemPackagePaths.cs", false);
      sw.WriteLine("using System.Collections.Generic;");
      sw.WriteLine("");
      sw.WriteLine("public static class GameSystemPackagePaths {");
      sw.WriteLine("  public static void AddName(Dictionary<string, string> arr) {");
      foreach (var k in sEditorLuaPath)
        sw.WriteLine("    arr.Add(\"" + k.Key + "\", \"" + k.Value.Substring(0, k.Value.Length - 4) + "\");");
      sw.WriteLine("  }");
      sw.WriteLine("}");
      sw.Close();

      EditorUtility.DisplayDialog("提示", "成功。复制 " + count + " 个文件", "确定");
    }
    [@MenuItem("Ballance/工具/编译系统脚本到 Reources SystemScrips 目录（x86）", false, 104)]
    public static void CopyScriptToReourcesFolderX86()
    {
      const string folderSrc = "Assets/System/Scripts/SystemScrips";
      const string folderTarget = "Assets/System/Resources/SystemScrips";
      int count = 0;
      EditorUtility.DisplayProgressBar("正在编译", "请稍后", 0);

      Dictionary<string, string> sEditorLuaPath = new Dictionary<string, string>();
      DirectoryInfo direction = new DirectoryInfo(folderSrc);
      FileInfo[] files = direction.GetFiles("*.lua", SearchOption.AllDirectories);
      for (int i = 0; i < files.Length; i++)
      {
        var rel = StringUtils.RemoveStringByStringStart(files[i].FullName.Replace('\\', '/'), folderSrc);
        var src = folderSrc + "/" + rel;
        var dest = folderTarget + "/" + rel + ".bytes";
        var dir = Path.GetDirectoryName(dest);
        if (!Directory.Exists(dir))
          Directory.CreateDirectory(dir);

        var fileName = Path.GetFileName(rel);
        var fileNameNoExt = Path.GetFileNameWithoutExtension(rel);
        if (!sEditorLuaPath.ContainsKey(fileName))
          sEditorLuaPath.Add(fileName, "SystemScrips" + rel);
        if (!sEditorLuaPath.ContainsKey(fileNameNoExt))
          sEditorLuaPath.Add(fileNameNoExt, "SystemScrips" + rel);

        var outPath = "";
        if (LuaCompiler.CompileLuaFile(src, true, out outPath))
        {
          File.Copy(outPath, dest, true);
          File.Delete(outPath);
        }
        else
        {
          Debug.LogError("编译 " + src + " 失败, 将lua文件原样打包。");
          File.Copy(src, dest, true);
        }

        EditorUtility.DisplayProgressBar("正在编译", rel, count / (float)files.Length);
        count++;
      }
      EditorUtility.ClearProgressBar();

      StreamWriter sw = new StreamWriter("Assets/System/Scripts/Package/EditorInfo/GameSystemPackagePaths.cs", false);
      sw.WriteLine("using System.Collections.Generic;");
      sw.WriteLine("");
      sw.WriteLine("public static class GameSystemPackagePaths {");
      sw.WriteLine("  public static void AddName(Dictionary<string, string> arr) {");
      foreach (var k in sEditorLuaPath)
        sw.WriteLine("    arr.Add(\"" + k.Key + "\", \"" + k.Value + "\");");
      sw.WriteLine("  }");
      sw.WriteLine("}");
      sw.Close();

      EditorUtility.DisplayDialog("提示", "成功。编译 " + count + " 个文件", "确定");
    }

    private static void CopyDebugFolder(string name, string debugFolder, string folder)
    {
      string folderCoreSrc = debugFolder + "/" + name;
      string folderCoreTarget = folder + "/" + name;
      if (Directory.Exists(folderCoreSrc))
      {
        if (!Directory.Exists(folderCoreTarget))
          Directory.CreateDirectory(folderCoreTarget);

        DirectoryInfo direction = new DirectoryInfo(folderCoreSrc);
        FileInfo[] files = direction.GetFiles("*", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
          if (files[i].Name.EndsWith(".ballance")
              || files[i].Name.EndsWith(".txt")
              || files[i].Name.EndsWith(".xml"))
          {
            File.Copy(
                folderCoreSrc + "/" + files[i].Name,
                folderCoreTarget + "/" + files[i].Name,
                true);
          }
        }
      }
    }
  }
}
