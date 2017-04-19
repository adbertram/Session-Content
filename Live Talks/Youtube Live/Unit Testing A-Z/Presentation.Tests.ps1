describe 'Presentation' {

    #$slideDeckPath = 'C:\DropBox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\slides.pptx'
    $slideDeckPath = "C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\slides.pptx"
    Add-type -AssemblyName office
    $script:application = New-Object -ComObject powerpoint.application
    $presentation = $script:application.Presentations.Open($slideDeckPath)
    $titleSlideTitle = ($presentation.Slides.Item(1).Shapes | ? {$_.Name -eq 'Title 1'}).TextFrame.textRange.Text
    
    it 'has the right title in the first slide' {
        $titleSlideTitle | should be 'Unit Testing A-Z with Pester'
    }
}