script.Parent.Index.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.Index.Visible = not script.Parent.Parent.Frames.Index.Visible
end)

script.Parent.Parent.Frames.Index.Top.Close.MouseButton1Click:Connect(function()  
	script.Parent.Parent.Frames.Index.Visible = false
end)
script.Parent.Store.MouseButton1Click:Connect(function()

	script.Parent.Parent.Frames.Store.Visible = not script.Parent.Parent.Frames.Store.Visible
end)

script.Parent.AdminAbuse.MouseButton1Click:Connect(function()
    script.Parent.Parent.Frames.AdminAbuse.Visible = not script.Parent.Parent.Frames.AdminAbuse.Visible
    if script.Parent.Parent.Frames.AdminAbuse.Visible == true then
        script.Sound:Play()
    end
end)

script.Parent.Parent.Frames.AdminAbuse.Top.Close.MouseButton1Click:Connect(function()
    script.Parent.Parent.Frames.AdminAbuse.Visible = false
end)