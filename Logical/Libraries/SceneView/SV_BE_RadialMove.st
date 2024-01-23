
(* TODO: Add your comment here *)
FUNCTION_BLOCK SV_BE_RadialMove
	IF Error THEN
		State := 50;
	ELSIF NOT Execute THEN
		State := 0;
	END_IF
	
	
	CASE State OF
		0:
			ElapsedTime := T#0s;
			PausedTime := T#0s;
			Done := FALSE;
			TON_ViewChange.IN := FALSE;
			
			IF Execute THEN
				IF (TIME_TO_REAL(TravelTime) = 0) THEN
					Error := TRUE;
				ELSE
					SceneViewPos := PointA;
					State := 1;
				END_IF
			END_IF
		
		1:
			
			AngleA := atan2((PointA.ViewPoint.Y - FocalPointA.Y),(PointA.ViewPoint.X - FocalPointA.X));
			AngleB := atan2((PointB.ViewPoint.Y - FocalPointB.Y),(PointB.ViewPoint.X - FocalPointB.X));
			
			RadiusA := (PointA.ViewPoint.X - FocalPointA.X) / COS(AngleA);
			RadiusB := (PointB.ViewPoint.X - FocalPointB.X) / COS(AngleB);
			
			SceneViewPos.Perspective := TRUE;
			
			RadiusChangeRate := (RadiusB - RadiusA) / TIME_TO_REAL(TravelTime);
			AngleChangeRate := (AngleB - AngleA) / TIME_TO_REAL(TravelTime);
			ChangeRate.Fov := (PointB.Fov - PointA.Fov) / TIME_TO_REAL(TravelTime);
			ChangeRate.Zoom := (PointB.Zoom - PointA.Zoom) / TIME_TO_REAL(TravelTime);
			ChangeRate.ViewPoint.X := (PointB.ViewPoint.X - PointA.ViewPoint.X) / TIME_TO_REAL(TravelTime);
			ChangeRate.ViewPoint.Y := (PointB.ViewPoint.Y - PointA.ViewPoint.Y) / TIME_TO_REAL(TravelTime);
			ChangeRate.ViewPoint.Z := (PointB.ViewPoint.Z - PointA.ViewPoint.Z) / TIME_TO_REAL(TravelTime);
			ChangeRate.OrientationVector.X := (PointB.OrientationVector.X - PointA.OrientationVector.X) / TIME_TO_REAL(TravelTime);
			ChangeRate.OrientationVector.Y := (PointB.OrientationVector.Y - PointA.OrientationVector.Y) / TIME_TO_REAL(TravelTime);
			ChangeRate.OrientationVector.Z := (PointB.OrientationVector.Z - PointA.OrientationVector.Z) / TIME_TO_REAL(TravelTime);
			FocalPointChangeRate.X := (FocalPointB.X - FocalPointA.X) / TIME_TO_REAL(TravelTime);
			FocalPointChangeRate.Y := (FocalPointB.Y - FocalPointA.Y) / TIME_TO_REAL(TravelTime);
			FocalPointChangeRate.Z := (FocalPointB.Z - FocalPointA.Z) / TIME_TO_REAL(TravelTime);
			
			TON_ViewChange.PT := TravelTime;
			State := 2;
			
		2:
			
			TON_ViewChange.IN := TRUE;
			
			FocalPointPos.X := (FocalPointA.X + FocalPointChangeRate.X * TIME_TO_REAL(TON_ViewChange.ET));
			FocalPointPos.Y := (FocalPointA.Y + FocalPointChangeRate.Y * TIME_TO_REAL(TON_ViewChange.ET));
			FocalPointPos.Z := (FocalPointA.Z + FocalPointChangeRate.Z * TIME_TO_REAL(TON_ViewChange.ET));
			
			OutputAngle := AngleA + AngleChangeRate * TIME_TO_REAL(TON_ViewChange.ET);
			OutputRadius := RadiusA + RadiusChangeRate * TIME_TO_REAL(TON_ViewChange.ET);
			
			SceneViewPos.ViewPoint.X := (OutputRadius * COS(OutputAngle)) + FocalPointPos.X;
			SceneViewPos.ViewPoint.Y := (OutputRadius * SIN(OutputAngle)) + FocalPointPos.Y;
			
			SceneViewPos.Fov := PointA.Fov + ChangeRate.Fov * TIME_TO_REAL(TON_ViewChange.ET);
			SceneViewPos.Zoom := PointA.Zoom + ChangeRate.Zoom * TIME_TO_REAL(TON_ViewChange.ET);
			SceneViewPos.ViewPoint.Z := PointA.ViewPoint.Z + ChangeRate.ViewPoint.Z * TIME_TO_REAL(TON_ViewChange.ET);
			SceneViewPos.ViewVector.X := (FocalPointPos.X - SceneViewPos.ViewPoint.X) / 1000.0;
			SceneViewPos.ViewVector.Y := (FocalPointPos.Y - SceneViewPos.ViewPoint.Y) / 1000.0;
			SceneViewPos.ViewVector.Z := (FocalPointPos.Z - SceneViewPos.ViewPoint.Z) / 1000.0;
			SceneViewPos.OrientationVector.X := PointA.OrientationVector.X + ChangeRate.OrientationVector.X * TIME_TO_REAL(TON_ViewChange.ET);
			SceneViewPos.OrientationVector.Y := PointA.OrientationVector.Y + ChangeRate.OrientationVector.Y * TIME_TO_REAL(TON_ViewChange.ET);
			SceneViewPos.OrientationVector.Z := PointA.OrientationVector.Z + ChangeRate.OrientationVector.Z * TIME_TO_REAL(TON_ViewChange.ET);
			 
			ElapsedTime := TON_ViewChange.ET + PausedTime;
			
			IF TON_ViewChange.Q THEN
				TON_ViewChange.IN := FALSE;
				State := 3;
			ELSIF Pause THEN
				FocalPointA.X := FocalPointPos.X;
				FocalPointA.Y := FocalPointPos.Y;
				FocalPointA.Z := FocalPointPos.Z;
				AngleA := OutputAngle;
				RadiusA := OutputRadius;
				
				
				PointA.OrientationVector.X := SceneViewPos.OrientationVector.X;
				PointA.OrientationVector.Y := SceneViewPos.OrientationVector.Y;
				PointA.OrientationVector.Z := SceneViewPos.OrientationVector.Z;
				PointA.Fov := SceneViewPos.Fov;
				PointA.Zoom := SceneViewPos.Zoom;
				PointA.ViewPoint.Z := SceneViewPos.ViewPoint.Z;
				
				RemainingTime := TravelTime - ElapsedTime;
				PausedTime := ElapsedTime;
				TON_ViewChange.PT := RemainingTime;
				
				TON_ViewChange.IN := FALSE;
				State := 10;
			END_IF
			
			
			
		
			
			

		3:
			Done := TRUE;
			
		10:
			Paused := TRUE;
			IF NOT Pause THEN
				Paused := FALSE;
				Pause := FALSE;
				State := 2;
			END_IF
			
		
		50:
			IF NOT Execute THEN
				Error := FALSE;
				State := 0;
			END_IF
		
	END_CASE
	
	TON_ViewChange();
	
END_FUNCTION_BLOCK
