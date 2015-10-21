require 'uri'

Given /^the only hosts in APT sources are "([^"]*)"$/ do |hosts_str|
  hosts = hosts_str.split(',')
  $vm.file_content("/etc/apt/sources.list /etc/apt/sources.list.d/*").chomp.each_line { |line|
    next if ! line.start_with? "deb"
    source_host = URI(line.split[1]).host
    if !hosts.include?(source_host)
      raise "Bad APT source '#{line}'"
    end
  }
end

When /^I update APT using apt$/ do
  Timeout::timeout(30*60) do
    $vm.execute_successfully("echo #{@sudo_password} | " +
                             "sudo -S apt update", LIVE_USER)
  end
end

Then /^I should be able to install a package using apt$/ do
  package = "cowsay"
  Timeout::timeout(120) do
    $vm.execute_successfully("echo #{@sudo_password} | " +
                             "sudo -S apt install #{package}", LIVE_USER)
  end
  step "package \"#{package}\" is installed"
end

When /^I update APT using Synaptic$/ do
  @screen.click('SynapticReloadButton.png')
  @screen.wait('SynapticReloadPrompt.png', 20)
  try_for(30*60) do
    begin
      @screen.waitVanish('SynapticReloadPrompt.png', 60)
    rescue Exception => e
      @screen.hover_point(0, 0)
      @screen.hide_cursor
      raise e
    end
  end
  # After this next image is displayed, the GUI should be responsive.
  @screen.wait('SynapticPackageList.png', 30)
end

Then /^I should be able to install a package using Synaptic$/ do
  package = "cowsay"
  @screen.wait_and_click(Sikuli::Pattern.new('SynapticSearchButton.png').exact, 10)
  @screen.wait('SynapticSearchWindow.png', 20)
  @screen.type(package + Sikuli::Key.ENTER)
  @screen.wait_and_double_click('SynapticCowsaySearchResult.png', 20)
  @screen.wait_and_click('SynapticApplyButton.png', 10)
  @screen.wait('SynapticApplyPrompt.png', 60)
  @screen.type(Sikuli::Key.ENTER)
  @screen.wait('SynapticChangesAppliedPrompt.png', 120)
  step "package \"#{package}\" is installed"
end

When /^I start Synaptic$/ do
  step 'I start "Synaptic" via the GNOME "System" applications menu'
  deal_with_polkit_prompt('PolicyKitAuthPrompt.png', @sudo_password)
  @screen.wait('SynapticReloadButton.png', 30)
end
