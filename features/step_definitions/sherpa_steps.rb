Then "it should emit the JSON:" do |json|
  match = all_output.match('\[^\]]+')
  match.should_not be_nil
  JSON.parse(match[0]).should == JSON.parse(json)
end
