package com.commontime.plugin;

import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.database.Cursor;
import android.net.Uri;
import android.support.v4.content.FileProvider;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URISyntaxException;

public class FileOpener extends CordovaPlugin
{
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException
    {
        String path = data.getString(0);

        Intent intent = new Intent(Intent.ACTION_VIEW);

        if(path.contains("file://"))
        {
            Uri uri = null;

            if(path.contains("file:///android_asset"))
            {
                uri = copyReadAssets(path);
                intent.setData(uri);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }
            else
            {
                path = path.replace("file://", "").replace("%20", " ");
                uri = FileProvider.getUriForFile(cordova.getActivity(), cordova.getActivity().getPackageName() + ".fileprovider", new File(path));
                intent.setData(uri);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }


        }
        else if(path.contains("http://"))
        {
            intent.setData(Uri.parse(path));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }

        try
        {
            cordova.getActivity().startActivity(Intent.createChooser(intent, "Open File With"));
        }
        catch (android.content.ActivityNotFoundException ex)
        {
            // Potentially direct the user to the Market with a Dialog
            callbackContext.error("No App Installed to Open File.");
        }

        return true;
    }

    public String getPath(Context context, Uri uri) throws URISyntaxException
    {
        if ("content".equalsIgnoreCase(uri.getScheme()))
        {
            String[] projection = { "_data" };
            Cursor cursor = null;

            try
            {
                cursor = context.getContentResolver().query(uri, projection, null, null, null);
                int column_index = cursor.getColumnIndexOrThrow("_data");

                if (cursor.moveToFirst())
                    return cursor.getString(column_index);
            }
            catch (Exception e)
            {
                // Eat it
            }
        }
        else if ("file".equalsIgnoreCase(uri.getScheme()))
        {
            return uri.getPath();
        }

        return null;
    }

    private Uri copyReadAssets(String path)
    {
        AssetManager assetManager = cordova.getActivity().getAssets();

        String fileName = path.substring(path.lastIndexOf("/")+1);

        InputStream in = null;
        OutputStream out = null;
        File file = new File(cordova.getActivity().getFilesDir(), fileName);
        try
        {
            in = assetManager.open(path.replace("file:///android_asset/", ""));
            out = cordova.getActivity().openFileOutput(file.getName(), Context.MODE_WORLD_READABLE);

            copyFile(in, out);
            in.close();
            in = null;
            out.flush();
            out.close();
            out = null;
        } catch (Exception e)
        {
            e.printStackTrace();
        }

        return Uri.fromFile(file);
    }

    private void copyFile(InputStream in, OutputStream out) throws IOException
    {
        byte[] buffer = new byte[1024];
        int read;
        while ((read = in.read(buffer)) != -1)
        {
            out.write(buffer, 0, read);
        }
    }

}