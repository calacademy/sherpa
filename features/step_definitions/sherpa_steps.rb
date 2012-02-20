Then "it should emit the JSON:" do |json|
  JSON.parse(all_output).should == JSON.parse(json)
end
