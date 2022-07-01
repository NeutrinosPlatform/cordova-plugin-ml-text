package com.neutrinos.mltextplugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;


public class Mltext extends CordovaPlugin {

	private static final int NORMFILEURI = 0; // Make bitmap without compression using uri from picture library (NORMFILEURI & NORMNATIVEURI have same functionality in android)
	private static final int NORMNATIVEURI = 1; // Make compressed bitmap using uri from picture library for faster ocr but might reduce accuracy (NORMFILEURI & NORMNATIVEURI have same functionality in android)
	private static final int FASTFILEURI = 2; // Make uncompressed bitmap using uri from picture library (FASTFILEURI & FASTFILEURI have same functionality in android)
	private static final int FASTNATIVEURI = 3; // Make compressed bitmap using uri from picture library for faster ocr but might reduce accuracy (FASTFILEURI & FASTFILEURI have same functionality in android)
	private static final int BASE64 = 4;  // send base64 image instead of uri

	@Override
	public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

		if (!action.equals("getText")) {
			return false;
		}

		cordova.getThreadPool().execute(() -> {
			try {
				int argstype;
				String imagestr = "";
				try {
					Log.d("argsbeech", args.toString());

					argstype = args.optInt(0, NORMFILEURI);
					imagestr = args.getString(1);
				} catch (Exception e) {
					callbackContext.error("Argument error");
					PluginResult r = new PluginResult(PluginResult.Status.ERROR);
					callbackContext.sendPluginResult(r);
					return;
				}

				if (imagestr.trim().isEmpty()) {
					callbackContext.error("Image Uri or Base64 string is empty");
					PluginResult r = new PluginResult(PluginResult.Status.ERROR);
					callbackContext.sendPluginResult(r);
					return;
				}

				Bitmap bitmap = null;

				if (argstype == NORMFILEURI || argstype == NORMNATIVEURI || argstype == FASTFILEURI || argstype == FASTNATIVEURI) {
					try {
						Uri uri = Uri.parse(imagestr);

						if ((argstype == NORMFILEURI || argstype == NORMNATIVEURI) && uri != null) { // normal ocr
							bitmap = MediaStore.Images.Media.getBitmap(cordova.getActivity().getBaseContext().getContentResolver(), uri);
						} else if ((argstype == FASTFILEURI || argstype == FASTNATIVEURI) && uri != null) { //fast ocr (might be less accurate)
							bitmap = decodeBitmapUri(cordova.getActivity().getBaseContext(), uri);
						}
					} catch (Exception e) {
						e.printStackTrace();
						callbackContext.error("Exception");
						PluginResult r = new PluginResult(PluginResult.Status.ERROR);
						callbackContext.sendPluginResult(r);
					}
				} else if (argstype == BASE64) {
					byte[] decodedString = Base64.decode(imagestr, Base64.DEFAULT);
					bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
				} else {
					callbackContext.error("Non existent argument. Use 0, 1, 2 , 3 or 4");
					PluginResult r = new PluginResult(PluginResult.Status.ERROR);
					callbackContext.sendPluginResult(r);
					return;
				}

				if (bitmap == null) {
					callbackContext.error("Error in uri or base64 data!");
					PluginResult r = new PluginResult(PluginResult.Status.ERROR);
					callbackContext.sendPluginResult(r);
					return;
				}

				TextRecognizer textRecognizer = TextRecognition.getClient(new TextRecognizerOptions.Builder().build());

				InputImage image = InputImage.fromBitmap(bitmap, 0);
				textRecognizer.process(image)
						.addOnSuccessListener(result ->
								handleTextRecognizerResult(callbackContext, result, image.getWidth(), image.getHeight()))
						.addOnFailureListener(e -> {
							callbackContext.error("Error with Text Recognition Module");
							PluginResult r = new PluginResult(PluginResult.Status.ERROR);
							callbackContext.sendPluginResult(r);
						});
			} catch (Exception e) {
				callbackContext.error("Main loop Exception");
				PluginResult r = new PluginResult(PluginResult.Status.ERROR);
				callbackContext.sendPluginResult(r);
			}
		});

		return true;
	}

	private void handleTextRecognizerResult(final CallbackContext callbackContext, Text result, int width, int height) {
		try {
			JSONObject resultObj = new JSONObject();

			if (result.getText().trim().isEmpty()) {
				resultObj.put("foundText", false);
				callbackContext.success(resultObj);
				PluginResult r = new PluginResult(PluginResult.Status.OK);
				callbackContext.sendPluginResult(r);
				return;
			}

			JSONObject blockObj = new JSONObject();
			JSONObject lineObj = new JSONObject();
			JSONObject wordObj = new JSONObject();

			JSONArray blockText = new JSONArray();
			JSONArray blockPoints = new JSONArray();
			JSONArray blockFrame = new JSONArray();

			JSONArray lineText = new JSONArray();
			JSONArray linePoints = new JSONArray();
			JSONArray lineFrame = new JSONArray();

			JSONArray wordText = new JSONArray();
			JSONArray wordPoints = new JSONArray();
			JSONArray wordFrame = new JSONArray();

			for (Text.TextBlock block : result.getTextBlocks()) {

				blockText.put(block.getText());

				JSONObject blockCorners = new JSONObject();
				if (block.getCornerPoints() == null) {
					blockCorners.put("x1", "");
					blockCorners.put("y1", "");

					blockCorners.put("x2", "");
					blockCorners.put("y2", "");

					blockCorners.put("x3", "");
					blockCorners.put("y3", "");

					blockCorners.put("x4", "");
					blockCorners.put("y4", "");
				} else {
					blockCorners.put("x1", block.getCornerPoints()[0].x);
					blockCorners.put("y1", block.getCornerPoints()[0].y);

					blockCorners.put("x2", block.getCornerPoints()[1].x);
					blockCorners.put("y2", block.getCornerPoints()[1].y);

					blockCorners.put("x3", block.getCornerPoints()[2].x);
					blockCorners.put("y3", block.getCornerPoints()[2].y);

					blockCorners.put("x4", block.getCornerPoints()[3].x);
					blockCorners.put("y4", block.getCornerPoints()[3].y);
				}

				blockPoints.put(blockCorners);

				JSONObject blockFrameobj = new JSONObject();
				if (block.getBoundingBox() == null) {
					blockFrameobj.put("x", "");
					blockFrameobj.put("y", "");
					blockFrameobj.put("height", "");
					blockFrameobj.put("width", "");
				} else {
					blockFrameobj.put("x", block.getBoundingBox().left);
					blockFrameobj.put("y", block.getBoundingBox().bottom);
					blockFrameobj.put("height", block.getBoundingBox().height());
					blockFrameobj.put("width", block.getBoundingBox().width());
				}

				blockFrame.put(blockFrameobj);

				for (Text.Line line : block.getLines()) {

					lineText.put(line.getText());

					JSONObject lineCorners = new JSONObject();

					if (line.getCornerPoints() == null) {
						lineCorners.put("x1", "");
						lineCorners.put("y1", "");
						lineCorners.put("x2", "");
						lineCorners.put("y2", "");

						lineCorners.put("x3", "");
						lineCorners.put("y3", "");

						lineCorners.put("x4", "");
						lineCorners.put("y4", "");
					} else {
						lineCorners.put("x1", line.getCornerPoints()[0].x);
						lineCorners.put("y1", line.getCornerPoints()[0].y);

						lineCorners.put("x2", line.getCornerPoints()[1].x);
						lineCorners.put("y2", line.getCornerPoints()[1].y);

						lineCorners.put("x3", line.getCornerPoints()[2].x);
						lineCorners.put("y3", line.getCornerPoints()[2].y);

						lineCorners.put("x4", line.getCornerPoints()[3].x);
						lineCorners.put("y4", line.getCornerPoints()[3].y);
					}

					linePoints.put(lineCorners);

					JSONObject lineFrameObj = new JSONObject();

					if (line.getBoundingBox() == null) {
						lineFrameObj.put("x", "");
						lineFrameObj.put("y", "");
						lineFrameObj.put("height", "");
						lineFrameObj.put("width", "");
					} else {
						lineFrameObj.put("x", line.getBoundingBox().left);
						lineFrameObj.put("y", line.getBoundingBox().bottom);
						lineFrameObj.put("height", line.getBoundingBox().height());
						lineFrameObj.put("width", line.getBoundingBox().width());
					}

					lineFrame.put(lineFrameObj);

					for (Text.Element element : line.getElements()) {

						wordText.put(element.getText());

						JSONObject wordCorners = new JSONObject();

						if (element.getCornerPoints() == null) {
							wordCorners.put("x1", "");
							wordCorners.put("y1", "");

							wordCorners.put("x2", "");
							wordCorners.put("y2", "");

							wordCorners.put("x3", "");
							wordCorners.put("y3", "");

							wordCorners.put("x4", "");
							wordCorners.put("y4", "");
						} else {
							wordCorners.put("x1", element.getCornerPoints()[0].x);
							wordCorners.put("y1", element.getCornerPoints()[0].y);

							wordCorners.put("x2", element.getCornerPoints()[1].x);
							wordCorners.put("y2", element.getCornerPoints()[1].y);

							wordCorners.put("x3", element.getCornerPoints()[2].x);
							wordCorners.put("y3", element.getCornerPoints()[2].y);

							wordCorners.put("x4", element.getCornerPoints()[3].x);
							wordCorners.put("y4", element.getCornerPoints()[3].y);
						}

						wordPoints.put(wordCorners);

						JSONObject wordFrameObj = new JSONObject();
						if (element.getBoundingBox() == null) {
							wordFrameObj.put("x", "");
							wordFrameObj.put("y", "");
							wordFrameObj.put("height", "");
							wordFrameObj.put("width", "");
						} else {
							wordFrameObj.put("x", element.getBoundingBox().left);
							wordFrameObj.put("y", element.getBoundingBox().bottom);
							wordFrameObj.put("height", element.getBoundingBox().height());
							wordFrameObj.put("width", element.getBoundingBox().width());
						}

						wordFrame.put(wordFrameObj);
					}
				}
			}

			blockObj.put("blocktext", blockText);
			blockObj.put("blockpoints", blockPoints);
			blockObj.put("blockframe", blockFrame);

			lineObj.put("linetext", lineText);
			lineObj.put("linepoints", linePoints);
			lineObj.put("lineframe", lineFrame);

			wordObj.put("wordtext", wordText);
			wordObj.put("wordpoints", wordPoints);
			wordObj.put("wordframe", wordFrame);

			resultObj.put("foundText", true);
			resultObj.put("blocks", blockObj);
			resultObj.put("lines", lineObj);
			resultObj.put("words", wordObj);
			resultObj.put("imgWidth", width);
			resultObj.put("imgHeight", height);
			resultObj.put("text", result.getText());

			callbackContext.success(resultObj);
			PluginResult r = new PluginResult(PluginResult.Status.OK);
			callbackContext.sendPluginResult(r);

		} catch (JSONException e) {
			callbackContext.error(String.valueOf(e));
			PluginResult r = new PluginResult(PluginResult.Status.ERROR);
			callbackContext.sendPluginResult(r);
		}
	}

	private Bitmap decodeBitmapUri(Context ctx, Uri uri) throws IOException {
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

		Bitmap bitmap = BitmapFactory.decodeStream(ctx.getContentResolver()
				.openInputStream(uri), null, bmOptions);

		ByteArrayInputStream ins = null;
		try(ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
			bitmap.compress(Bitmap.CompressFormat.JPEG, 50, baos);
			ins = new ByteArrayInputStream(baos.toByteArray());
			bitmap = BitmapFactory.decodeStream(ins);
		} finally {
			if (ins != null) {
				ins.close();
			}
		}

		return bitmap;
	}
}
