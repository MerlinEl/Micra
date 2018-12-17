1	turretRotChange = 0f; 
2	            //Adjust the rotation value 
3	            if (Keyboard.GetState().IsKeyDown(Keys.L)) 
4	                turretRotChange += 0.05f; 
5	            if (Keyboard.GetState().IsKeyDown(Keys.R)) 
6	                turretRotChange -= 0.05f; 
7	 
8	            if (Keyboard.GetState().IsKeyDown(Keys.N) && 
9	                lastKeyboardState.IsKeyUp(Keys.N)) 
10	            { 
11	                boneToMove++; 
12	                if (boneToMove > myModel.Bones.Count - 1) 
13	                    boneToMove = myModel.Bones.Count - 1; 
14	            } 
15	            if (Keyboard.GetState().IsKeyDown(Keys.P) && 
16	                lastKeyboardState.IsKeyUp(Keys.P)) 
17	            { 
18	                boneToMove--; 
19	                if (boneToMove < 0) 
20	                    boneToMove = 0; 
21	            } 
22	 
23	myModel.Bones["Turret"].Transform = Matrix.CreateRotationY(turretRotChange) * myModel.Bones["Turret"].Transform; 
24	myModel.CopyAbsoluteBoneTransformsTo(modelTransforms); 
25	 
26	            //Set the new transforms 
27	            //Matrix t = originalTransforms[boneToMove] *  
28	            //    Matrix.CreateRotationZ(turretRot); 
29	            //myModel.Bones[boneToMove].Transform = t; 
30	 
31	            //Set the last keyboard state for next frame 
32	            lastKeyboardState = Keyboard.GetState(); 






1	protected override void Update(GameTime gameTime) 
2	{ 
3	    // Allows the game to exit 
4	    if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed) 
5	        this.Exit(); 
6	 
7	    gunPitch += GamePad.GetState(PlayerIndex.One).ThumbSticks.Left.Y * 0.01f; 
8	    turretYaw += GamePad.GetState(PlayerIndex.One).ThumbSticks.Left.X * 0.01f; 
9	 
10	    gun.Bones["turret"].Transform = Matrix.CreateRotationZ(turretYaw) * originalTransforms[gun.Bones["turret"].Index]; 
11	    gun.Bones["turret"].Transform = Matrix.CreateRotationY(gunPitch) * gun.Bones["turret"].Transform; 
12	 
13	    gun.Bones["leftCannon"].Transform = Matrix.CreateRotationZ(0.1f) * gun.Bones["leftCannon"].Transform; 
14	 
15	 
16	    gun.CopyAbsoluteBoneTransformsTo(gunTransforms); 
17	 
18	    //world *= Matrix.CreateRotationZ(0.001f); 
19	 
20	    base.Update(gameTime); 
21	} 