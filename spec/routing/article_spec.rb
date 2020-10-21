require "rails_helper"

describe "articles routes" do
  it "should route to article index" do
    expect(get "/articles").to route_to("articles#index")
  end

  it "should route to article 1 on show" do
    expect(get "/articles/1").to route_to("articles#show", id: "1")
  end
end
