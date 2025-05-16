app: windows_explorer
app: windows_file_browser
-
tag(): user.address
tag(): user.file_manager
tag(): user.navigation

go app data: user.file_manager_open_directory("%AppData%")
go program files: user.file_manager_open_directory("%ProgramFiles%")
go videos: user.file_manager_open_directory("videos")
go documents: user.file_manager_open_directory("documents")
manager new: key(ctrl-n)
