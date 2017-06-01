Configuration Default {
    node 'localhost' {
        File TestFile {
            Ensure = 'Present'
            DestinationPath = 'C:\test.txt'
            Contents = 'This is working'            
        }
    }
}