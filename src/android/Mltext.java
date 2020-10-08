package com.neutrinos.mltextplugin;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import androidx.annotation.NonNull;

import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;

import java.io.FileNotFoundException;
import java.util.Objects;


public class Mltext extends CordovaPlugin {

    private static final int NORMFILEURI = 0; // Make bitmap without compression using uri from picture library (NORMFILEURI & NORMNATIVEURI have same functionality in android)
    private static final int NORMNATIVEURI = 1; // Make compressed bitmap using uri from picture library for faster ocr but might reduce accuracy (NORMFILEURI & NORMNATIVEURI have same functionality in android)
    private static final int FASTFILEURI = 2; // Make uncompressed bitmap using uri from picture library (FASTFILEURI & FASTFILEURI have same functionality in android)
    private static final int FASTNATIVEURI = 3; // Make compressed bitmap using uri from picture library for faster ocr but might reduce accuracy (FASTFILEURI & FASTFILEURI have same functionality in android)
    private static final int BASE64 = 4;  // send base64 image instead of uri

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action.equals("getText")) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                            int argstype = NORMFILEURI;
                            String argimagestr = "";
                        try
                        {
                            Log.d("argsbeech", args.toString());

                            argstype = args.getInt(0);
                            argimagestr = args.getString(1);
                        }
                        catch(Exception e)
                        {
                        callbackContext.error("Argument error");
                        PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                        callbackContext.sendPluginResult(r);
                        }
                        Bitmap bitmap= null;
                        Uri uri = null;
                        if(argstype==NORMFILEURI || argstype==NORMNATIVEURI||argstype==FASTFILEURI || argstype==FASTNATIVEURI)
                        {
                            try
                            {
                                if(!argimagestr.trim().equals(""))
                                {
                                        String imagestr = argimagestr;

                                        // code block that allows this plugin to directly work with document scanner plugin and camera plugin
                                        if(imagestr.substring(0,6).equals("file://"))
                                        {
                                            imagestr = argimagestr.replaceFirst("file://","");
                                        }
                                        //

                                        uri = Uri.parse(imagestr);

                                        if((argstype==NORMFILEURI || argstype==NORMNATIVEURI)&& uri != null) // normal ocr
                                        {
                                            bitmap = MediaStore.Images.Media.getBitmap(cordova.getActivity().getBaseContext().getContentResolver(), uri);
                                        }
                                        else if((argstype==FASTFILEURI || argstype==FASTNATIVEURI) && uri != null) //fast ocr (might be less accurate)
                                        {
                                            bitmap = decodeBitmapUri(cordova.getActivity().getBaseContext(), uri);
                                        }

                                }
                                else
                                {
                                    callbackContext.error("Image Uri or Base64 string is empty");
                                    PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                    callbackContext.sendPluginResult(r);
                                }
                            }
                            catch (Exception e)
                            {
                                e.printStackTrace();
                                callbackContext.error("Exception");
                                PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                callbackContext.sendPluginResult(r);
                            }
                        }
                        else if (argstype==BASE64)
                        {
                            if(!argimagestr.trim().equals(""))
                            {
                                byte[] decodedString = Base64.decode(argimagestr, Base64.DEFAULT);
                                bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                            }
                            else
                            {
                                callbackContext.error("Image Uri or Base64 string is empty");
                                PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                callbackContext.sendPluginResult(r);
                            }
                        }
                        else
                        {
                            callbackContext.error("Non existent argument. Use 0, 1, 2 , 3 or 4");
                            PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                            callbackContext.sendPluginResult(r);
                        }

                        TextRecognizer textRecognizer = TextRecognition.getClient();

                        if (bitmap != null)
                        {
                            InputImage image = InputImage.fromBitmap(bitmap,0);
                            textRecognizer.process(image)
                                    .addOnSuccessListener(result -> {
                                        try
                                        {
                                            JSONObject resultobj = new JSONObject();

                                            JSONObject blockobj = new JSONObject();
                                            JSONObject lineobj = new JSONObject();
                                            JSONObject wordobj = new JSONObject();

                                            JSONArray blocktext = new JSONArray();
                                            JSONArray blockpoints = new JSONArray();
                                            JSONArray blockframe = new JSONArray();

                                            JSONArray linetext = new JSONArray();
                                            JSONArray linepoints = new JSONArray();
                                            JSONArray lineframe = new JSONArray();

                                            JSONArray wordtext = new JSONArray();
                                            JSONArray wordpoints = new JSONArray();
                                            JSONArray wordframe = new JSONArray();

                                            if(result.getText().trim().equals(""))
                                            {
                                                callbackContext.error("No text found in image");
                                                PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                                callbackContext.sendPluginResult(r);
                                            }
                                            else
                                            {

                                                for (Text.TextBlock block : result.getTextBlocks())
                                                {

                                                    blocktext.put(block.getText());

                                                    JSONObject blockcorners = new JSONObject();
                                                    if (block.getCornerPoints()==null){
                                                        blockcorners.put("x1", "");
                                                        blockcorners.put("y1", "");

                                                        blockcorners.put("x2", "");
                                                        blockcorners.put("y2", "");

                                                        blockcorners.put("x3", "");
                                                        blockcorners.put("y3", "");

                                                        blockcorners.put("x4", "");
                                                        blockcorners.put("y4", "");
                                                    }
                                                    else {
                                                        blockcorners.put("x1", Objects.requireNonNull(block.getCornerPoints())[0].x);
                                                        blockcorners.put("y1", Objects.requireNonNull(block.getCornerPoints())[0].y);

                                                        blockcorners.put("x2", Objects.requireNonNull(block.getCornerPoints())[1].x);
                                                        blockcorners.put("y2", Objects.requireNonNull(block.getCornerPoints())[1].y);

                                                        blockcorners.put("x3", Objects.requireNonNull(block.getCornerPoints())[2].x);
                                                        blockcorners.put("y3", Objects.requireNonNull(block.getCornerPoints())[2].y);

                                                        blockcorners.put("x4", Objects.requireNonNull(block.getCornerPoints())[3].x);
                                                        blockcorners.put("y4", Objects.requireNonNull(block.getCornerPoints())[3].y);
                                                    }

                                                    blockpoints.put(blockcorners);

                                                    JSONObject blockframeobj = new JSONObject();
                                                    if (block.getBoundingBox()==null)
                                                    {
                                                        blockframeobj.put("x", "");
                                                        blockframeobj.put("y", "");
                                                        blockframeobj.put("height","");
                                                        blockframeobj.put("width", "");
                                                    }
                                                    else {
                                                        blockframeobj.put("x", block.getBoundingBox().left);
                                                        blockframeobj.put("y", block.getBoundingBox().bottom);
                                                        blockframeobj.put("height", block.getBoundingBox().height());
                                                        blockframeobj.put("width", block.getBoundingBox().width());
                                                    }

                                                    blockframe.put(blockframeobj);

                                                    for (Text.Line line : block.getLines())
                                                    {

                                                        linetext.put(line.getText());

                                                        JSONObject linecorners = new JSONObject();

                                                        if (line.getCornerPoints()==null){
                                                            linecorners.put("x1", "");
                                                            linecorners.put("y1", "");

                                                            linecorners.put("x2", "");
                                                            linecorners.put("y2", "");

                                                            linecorners.put("x3", "");
                                                            linecorners.put("y3", "");

                                                            linecorners.put("x4", "");
                                                            linecorners.put("y4", "");
                                                        }
                                                        else {
                                                            linecorners.put("x1", line.getCornerPoints()[0].x);
                                                            linecorners.put("y1", line.getCornerPoints()[0].y);

                                                            linecorners.put("x2", line.getCornerPoints()[1].x);
                                                            linecorners.put("y2", line.getCornerPoints()[1].y);

                                                            linecorners.put("x3", line.getCornerPoints()[2].x);
                                                            linecorners.put("y3", line.getCornerPoints()[2].y);

                                                            linecorners.put("x4", line.getCornerPoints()[3].x);
                                                            linecorners.put("y4", line.getCornerPoints()[3].y);
                                                        }

                                                        linepoints.put(linecorners);

                                                        JSONObject lineframeobj = new JSONObject();

                                                        if (line.getBoundingBox()==null)
                                                        {
                                                            lineframeobj.put("x", "");
                                                            lineframeobj.put("y", "");
                                                            lineframeobj.put("height","");
                                                            lineframeobj.put("width", "");
                                                        }
                                                        else
                                                        {
                                                            lineframeobj.put("x", line.getBoundingBox().left);
                                                            lineframeobj.put("y", line.getBoundingBox().bottom);
                                                            lineframeobj.put("height", line.getBoundingBox().height());
                                                            lineframeobj.put("width", line.getBoundingBox().width());
                                                        }


                                                        lineframe.put(lineframeobj);

                                                        for (Text.Element element : line.getElements())
                                                        {

                                                            wordtext.put(element.getText());

                                                            JSONObject wordcorners = new JSONObject();

                                                            if (element.getCornerPoints()==null)
                                                            {
                                                                wordcorners.put("x1", "");
                                                                wordcorners.put("y1", "");

                                                                wordcorners.put("x2", "");
                                                                wordcorners.put("y2", "");

                                                                wordcorners.put("x3", "");
                                                                wordcorners.put("y3", "");

                                                                wordcorners.put("x4", "");
                                                                wordcorners.put("y4", "");
                                                            }
                                                            else
                                                            {
                                                                wordcorners.put("x1", element.getCornerPoints()[0].x);
                                                                wordcorners.put("y1", element.getCornerPoints()[0].y);

                                                                wordcorners.put("x2", element.getCornerPoints()[1].x);
                                                                wordcorners.put("y2", element.getCornerPoints()[1].y);

                                                                wordcorners.put("x3", element.getCornerPoints()[2].x);
                                                                wordcorners.put("y3", element.getCornerPoints()[2].y);

                                                                wordcorners.put("x4", element.getCornerPoints()[3].x);
                                                                wordcorners.put("y4", element.getCornerPoints()[3].y);
                                                            }

                                                            wordpoints.put(wordcorners);

                                                            JSONObject wordframeobj = new JSONObject();
                                                            if (element.getBoundingBox()==null)
                                                            {
                                                                wordframeobj.put("x", "");
                                                                wordframeobj.put("y", "");
                                                                wordframeobj.put("height","");
                                                                wordframeobj.put("width", "");
                                                            }
                                                            else
                                                            {
                                                                wordframeobj.put("x", element.getBoundingBox().left);
                                                                wordframeobj.put("y", element.getBoundingBox().bottom);
                                                                wordframeobj.put("height", element.getBoundingBox().height());
                                                                wordframeobj.put("width", element.getBoundingBox().width());
                                                            }



                                                            wordframe.put(wordframeobj);
                                                            //wordframe.put(element.getBoundingBox());

                                                        }
                                                    }
                                                }


                                                blockobj.put("blocktext", blocktext);
                                                blockobj.put("blockpoints", blockpoints);
                                                blockobj.put("blockframe", blockframe);

                                                lineobj.put("linetext", linetext);
                                                lineobj.put("linepoints", linepoints);
                                                lineobj.put("lineframe", lineframe);

                                                wordobj.put("wordtext", wordtext);
                                                wordobj.put("wordpoints", wordpoints);
                                                wordobj.put("wordframe", wordframe);

                                                resultobj.put("blocks", blockobj);
                                                resultobj.put("lines", lineobj);
                                                resultobj.put("words", wordobj);

                                                callbackContext.success(resultobj);
                                                PluginResult r = new PluginResult(PluginResult.Status.OK);
                                                callbackContext.sendPluginResult(r);
                                            }
                                        }
                                        catch (JSONException e)
                                        {
                                            callbackContext.error(String.valueOf(e));
                                            PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                            callbackContext.sendPluginResult(r);
                                        }
                                    })
                                    .addOnFailureListener(
                                            new OnFailureListener() {
                                                @Override
                                                public void onFailure(@NonNull Exception e) {
                                                    callbackContext.error("Error with Text Recognition Module");
                                                    PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                                                    callbackContext.sendPluginResult(r);
                                                }
                                            });

                        }
                        else
                        {
                            callbackContext.error("Error in uri or base64 data!");
                            PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                            callbackContext.sendPluginResult(r);
                        }
                    } catch (Exception e) {
                        callbackContext.error("Main loop Exception");
                        PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                        callbackContext.sendPluginResult(r);
                    }
                }
            });

            return true;

        }
            return false;
    }


    private Bitmap decodeBitmapUri(Context ctx, Uri uri) throws FileNotFoundException
    {
        int targetW = 600;
        int targetH = 600;
        BitmapFactory.Options bmOptions = new BitmapFactory.Options();
        bmOptions.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(ctx.getContentResolver().openInputStream(uri), null, bmOptions);
        int photoW = bmOptions.outWidth;
        int photoH = bmOptions.outHeight;

        int scaleFactor = Math.min(photoW / targetW, photoH / targetH);
        bmOptions.inJustDecodeBounds = false;
        bmOptions.inSampleSize = scaleFactor;

        return BitmapFactory.decodeStream(ctx.getContentResolver()
                .openInputStream(uri), null, bmOptions);
    }
}
