share_as :AnyPageable do

  it "should be able to specify the number of results per page" do
    @search.per_page(10)
    @search.query["$top"].should == 10
  end

  it "should be able to specify the page number" do
    @search.page(3)
    @search.query["$skip"].should == 20 * 2
  end

end