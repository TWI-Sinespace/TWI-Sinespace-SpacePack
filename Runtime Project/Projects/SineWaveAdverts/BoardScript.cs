using System;
using UnityEngine;

public class BoardScript : MonoBehaviour {
	
	private Vector2[] TestPositions = new Vector2[9] {
		new Vector2(0,0),
		new Vector2(0, 0.5f),
		new Vector2(0, 1),
		new Vector2(0.5f, 0),
		new Vector2(0.5f, 0.5f), 
		new Vector2(0.5f, 1),
		new Vector2(1,0),
		new Vector2(1,0.5f),
		new Vector2(1,1)
	};
	
	public Texture2D DebugTexture;
	public Texture2D DebugMarker;
	public string BoardName = "New Adboard";
	public int BoardId = 0;
	private float minimumAngle = 0.7f; // Should be 0.5f in production?
	private float shearFactor = 0.40f; // Maximum shear %.
	
	private Validity[] ValidPositions = new Validity[9];
	
	public bool IsFacing;
	public bool IsTooSheared;
	public bool IsVisible;
	public bool IsOccluded;
	
	public bool IsValid;
	
	public bool _Debug;
	
	private float validAndVisibleTime;
	private float requiredVisibleTime = 10f;
	private float transitionTime;
	private float transitionLength = 3f;
	private bool transitionRunning;
	
	private enum Validity {
		Offscreen,
		Occluded,
		TooFar,
		Valid
	}
	
	// Use this for initialization
	void Start () {
		
		// A stable identifier
		BoardId = Math.Abs(
			gameObject.GetInstanceID()
			);
		
		// Set Material Properties
	    var rend = gameObject.GetComponent<Renderer>();
	    rend.materials[0].SetTexture("_Alpha", AlphaTexture);
		rend.materials[0].SetTexture("_Beta", BetaTexture);
		rend.materials[0].SetFloat("_Wipe", 0f);
	}
	
	void OnBecameVisible() {
		IsVisible = true;
	}
	
	void OnBecameInvisible() {
		IsVisible = false;
	}
	
	public Texture2D AlphaTexture;
	public Texture2D BetaTexture;
	
	void Update () {
		if(transitionRunning) {
			transitionTime += Time.deltaTime;
            var ren = gameObject.GetComponent<Renderer>();

		    ren.materials[0].SetFloat("_Wipe", Mathf.Min(1.0f, transitionTime / transitionLength));
			
			if(transitionTime >= transitionLength) {
				// Reset for next ad
				validAndVisibleTime = 0f;
				transitionTime = 0f; 
				transitionRunning = false;
				
				// Do silent texture swap.
				var Tmp = AlphaTexture;
				AlphaTexture = BetaTexture;
				BetaTexture = Tmp;
				ren.materials[0].SetTexture("_Alpha", AlphaTexture);
				ren.materials[0].SetTexture("_Beta", BetaTexture);
				ren.materials[0].SetFloat("_Wipe", 0f);
			}
			return;
		}
		
		
		// Calculating shear
		Vector3 s0, s1, s2;
		s0 = AdvertScreenPos(new Vector2(0,0));
		s1 = AdvertScreenPos(new Vector2(0,1));
		s2 = AdvertScreenPos(new Vector2(1,0));
		
		s1 -= s0;
		s2 -= s0; 
		
		float w = s2.x;
		float h = s1.y;
		
		float shear = w / h;
		float targetShear = gameObject.transform.localScale.x / gameObject.transform.localScale.z;
		
		if(shear > targetShear * (1f - shearFactor) && shear < targetShear * (1f + shearFactor)) {
			IsTooSheared = false;
		} else {
			IsTooSheared = true;	
		}
		
		// Check facing & minimum angle
		if(Vector3.Dot(CameraManager.MainCamera.transform.forward, -gameObject.transform.up) < minimumAngle) {
			IsFacing = false;
		} else {
			IsFacing = true;	
		}
		
		IsOccluded = false;
		
		// Checking for occlusion
		for(int i = 0; i < TestPositions.Length; i++) {
			ValidPositions[i] = TestAdvert(TestPositions[i]);
			if(ValidPositions[i] != Validity.Valid)
				IsOccluded = true;
		}
		
		IsValid = (IsVisible && IsFacing && !IsTooSheared && !IsOccluded);
		
		if(IsValid) {
			validAndVisibleTime += Time.deltaTime; // It's valid. Add some time to the counter.
		}
		
		if(validAndVisibleTime > requiredVisibleTime) {
			validAndVisibleTime = requiredVisibleTime;
			
			// Do reporting.
			
			// Initiate transition to next advertisement
			transitionRunning = true;
		}
	}
	
	private Color DebugValidityColor(Validity states) {
		switch(states) {
			case Validity.Occluded:
				return Color.gray;
			case Validity.Offscreen:
				return Color.yellow;
			case Validity.TooFar: 
				return Color.red;
			case Validity.Valid:
				return Color.green;
		}
		return Color.white;
	}
	
	void OnGUI() {
		if(!_Debug)
			return;
		
		if(!IsVisible)
			return;
		
		// Display outer box
		Vector3 s0, s1, s2, s3;
		s0 = AdvertScreenPos(new Vector2(0,0));
		s1 = AdvertScreenPos(new Vector2(1,0));
		s2 = AdvertScreenPos(new Vector2(0,1));
		s3 = AdvertScreenPos(new Vector2(1,1));
		
		float off = 16f;
		
		float minX = Mathf.Min(s0.x,s1.x,s2.x,s3.x) - off;
		float maxX = Mathf.Max(s0.x,s1.x,s2.x,s3.x) + off;
		float minY = Mathf.Min(s0.y,s1.y,s2.y,s3.y) - off;
		float maxY = Mathf.Max(s0.y,s1.y,s2.y,s3.y) + off;
		
		Rect bounds = new Rect(minX, Screen.height - maxY, Mathf.Abs(maxX - minX), Mathf.Abs(maxY - minY));
		
		int size = 32;
		Rect c0 = new Rect(bounds.xMin, bounds.yMin, size * 0.5f, size * 0.5f);
		Rect c1 = new Rect(bounds.xMin, bounds.yMax, size * 0.5f, size * 0.5f);
		Rect c2 = new Rect(bounds.xMax, bounds.yMin, size * 0.5f, size * 0.5f);
		Rect c3 = new Rect(bounds.xMax, bounds.yMax, size * 0.5f, size * 0.5f);
		
		GUI.color = (IsVisible && IsFacing && !IsTooSheared && !IsOccluded) ? Color.white : Color.red;
		
		GUI.DrawTextureWithTexCoords(c0, DebugTexture, new Rect(0.0f	,0.5f	,0.5f,0.5f));
		GUI.DrawTextureWithTexCoords(c1, DebugTexture, new Rect(0.0f	,0.0f	,0.5f,0.5f));
		GUI.DrawTextureWithTexCoords(c2, DebugTexture, new Rect(0.5f	,0.5f	,0.5f,0.5f));
		GUI.DrawTextureWithTexCoords(c3, DebugTexture, new Rect(0.5f	,0.0f	,0.5f,0.5f));
		
		Rect label = new Rect(c0.xMin + 8f, c0.yMin + 5f, bounds.width, bounds.height);
		
		GUI.color = Color.white;
		
		if(true) {
			// Display nodes
			size = 32;
			for(int i = 0; i < TestPositions.Length; i++) {
				if(ValidPositions[i] != Validity.Offscreen) {
					Vector3 tmpPos = AdvertScreenPos(TestPositions[i]);
					GUI.color = DebugValidityColor(ValidPositions[i]);
					Rect pos = new Rect(tmpPos.x - (size / 2), (Screen.height - tmpPos.y) - (size / 2), size, size);
					GUI.DrawTexture(pos, DebugMarker);
				}
			}
		}
		
		GUI.color = Color.white;
		
		float validPercent = 100f * (validAndVisibleTime / requiredVisibleTime);
		
		GUI.Label(label, BoardName + " " + BoardId);// + "\n" + "Visible: " + IsVisible + "\nFacing: " + IsFacing + "\nSheared: " + IsTooSheared);
		
		if(validPercent != 100.0f) {
			GUI.color = Color.gray;
		}
		
		GUI.Label(label,"\nCompleted: " + (int)validPercent + "%");
		
		GUI.color = Color.white;
	}
	
	void SwapAdvert() {
		
	}
	
	Vector3 AdvertScreenPos(Vector2 testPos) {
		testPos -= new Vector2(0.5f, 0.5f);
		float scaleFac = 10f * 0.98f; // .98f = 2% Margin of error. (Right on the edge will be subject to rounding and other errors.)
		testPos *= scaleFac;
		Vector3 targetPos = transform.TransformPoint(testPos.x, 0f, testPos.y);
		Vector3 screenPos = CameraManager.MainCamera.WorldToScreenPoint(targetPos);
		
		return screenPos;
	}
	
	Validity TestAdvert(Vector2 testPos) {
		
		Vector3 screenPos = AdvertScreenPos(testPos);
		
		if(
			screenPos.x < 0 || 
			screenPos.y < 0 || 
			screenPos.x > Screen.currentResolution.width || 
			screenPos.y > Screen.currentResolution.height
			) 
		{
			// Offscreen
			return Validity.Offscreen;
		}
		
		
		Ray testRay = CameraManager.MainCamera.ScreenPointToRay(screenPos);
		
		RaycastHit hit;
		
		if(Physics.Raycast(testRay, out hit)) {
			// Return whether we raycasted our own object.
			bool valid = hit.collider.gameObject == gameObject;

			return valid ? Validity.Valid : Validity.Occluded;
		}
		
		// Didn't hit our object?
		return Validity.TooFar;
	}
}
