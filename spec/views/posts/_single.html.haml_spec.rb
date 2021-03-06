require 'rails_helper'

describe "posts/_single" do

  def render_post()
      render :partial => "single", :locals => { :post => @post }
  end

  before(:each) do
    @post = FactoryGirl.create(:post)
    controller.stub(:current_user) { nil }
  end

  context "when the number of comments doesn't matter" do
    before(:each) do
      render_post
    end

    it "contains a permanent link to post" do
      assert_select "a[href=#{post_path @post}]", "Permalink"
    end

    it "doesn't contain a link to new comment" do
      assert_select "a[href=#{new_comment_path(:post_id => @post.id)}]", false
    end
  end

  context "when logged in" do
    before(:each) do
      @member = FactoryGirl.create(:member)
      sign_in @member
      controller.stub(:current_user) { @member }
      render_post
    end

    it "contains link to new comment" do
      assert_select "a[href=#{new_comment_path(:post_id => @post.id)}]", "Reply"
    end

    it "does not contain an edit link" do
      assert_select "a[href=#{edit_post_path(@post)}]", false
    end
  end

  context "when logged in as post author" do
    before(:each) do
      @member = FactoryGirl.create(:member)
      sign_in @member
      controller.stub(:current_user) { @member }
      @post = FactoryGirl.create(:post, :author => @member)
      render_post
    end

    it "contains an edit link" do
      assert_select "a[href=#{edit_post_path(@post)}]", "Edit"
    end
  end

  context "when there are no comments" do
    before(:each) do
      render_post
    end

    it "renders the number of comments" do
      assert_select "a[href=#{post_path(@post)}\#comments]", "0 comments"
    end
  end

  context "when there is 1 comment" do
    before(:each) do
      @comment = FactoryGirl.create(:comment, :post => @post)
      render_post
    end

    it "renders the number of comments" do
      assert_select "a[href=#{post_path(@post)}\#comments]", "1 comment"
    end
  end

  context "when there are 2 comments" do
    before(:each) do
      @comment = FactoryGirl.create(:comment, :post => @post)
      @comment2 = FactoryGirl.create(:comment, :post => @post)
      render_post
    end

    it "renders the number of comments" do
      assert_select "a[href=#{post_path(@post)}\#comments]", "2 comments"
    end
  end

  context "when comments should be hidden" do
    before(:each) do
      @member = FactoryGirl.create(:member)
      sign_in @member
      controller.stub(:current_user) { @member }
      @comment = FactoryGirl.create(:comment, :post => @post)
      render :partial => "single", :locals => {
        :post => @post, :hide_comments => true
      }
    end

    it "renders no value of comments" do
      rendered.should_not have_content "1 comment"
    end

    it "does not contain link to post" do
     assert_select "a[href=#{post_path @post}]", false
    end

    it "does not contain link to new comment" do
      assert_select "a[href=#{new_comment_path(:post_id => @post.id)}]", false
    end

  end
end



 
