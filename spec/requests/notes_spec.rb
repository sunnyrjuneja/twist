require 'spec_helper'

describe "notes" do
  let(:author) { create_author! }
  before do
    create_book!
    actually_sign_in_as(author)
  end
    
  it "can add a new note to a paragraph and leave a comment on it", :js => true do
    visit book_chapter_path(@book, @book.chapters.first)

    within "#note_button_ch01_3" do
      click_link "0 notes +"
    end

    fill_in "note_text", :with => "This is a **test** note!"
    click_button "Leave Note"
    page.should have_content("1 note +")
    click_link "All notes for this chapter"
    click_link "This is a test note!"
    page.should have_content("user@example.com started a discussion less than a minute ago")
    # Ensure note text shows up correctly in processed markdown.
    within ".review-note" do
      within(".body") do
        within("strong") { page.should have_content("test") }
      end
    end

    # And the rest of it.
    page.should have_content("This is a test note!")
    
    fill_in "comment_text", :with => "**This** _is_ a `comment`. Fixed in @edc32b4f1ecc7f43dcfae57c02b90df98c1b38f9."
    click_button "Leave Comment"
    page.should have_content("Comment has been created.")
    within "#comments" do
      within("p") do
        # Ensure comment text shows up correctly in processed markdown.
        within("strong") { page.should have_content("This") }
        within("em") { page.should have_content("is") }
        within("code") { page.should have_content("comment") }
        find("a")["href"].should == "https://github.com/twist-books/rails-3-in-action/commit/edc32b4f1ecc7f43dcfae57c02b90df98c1b38f9"
      end
    end
  end
  
  it "can view all notes for a book" do
    chapter = @book.chapters.first
    chapter.notes.create!(:text => "This is a test note!", 
                          :user => author, 
                          :number => 1,
                          :element => chapter.elements.first)
    
    visit book_path(@book)
    click_link "All notes for this book"
    click_link "This is a test note!"
    page.should have_content("user@example.com started a discussion less than a minute ago")
    page.should have_content("This is a test note!")
  end

  context "changing a note's state" do
    before do
      chapter = @book.chapters.first
      @note = chapter.notes.create!(:text => "This is a test note!", 
                                    :user => author, 
                                    :number => 1,
                                    :element => chapter.elements.first)
      
      visit book_path(@book)
      click_link "All notes for this book"
      click_link "This is a test note!"
    end

    it "can accept a note" do
      click_button "Accept"
      page.should have_content("Note state changed to Accepted")
    end

    it "can reject a note" do
      click_button "Reject"
      page.should have_content("Note state changed to Rejected")
    end
  end

  it "can reopen a note" do
    chapter = @book.chapters.first
    note = chapter.notes.create!(:text => "This is a test note!", 
                                 :user => author, 
                                 :number => 1,
                                 :element => chapter.elements.first,
                                 :state => "complete")
    
    visit book_path(@book)
    click_link "All notes for this book"
    page.should_not have_content("This is a test note!")
    visit book_note_path(@book, note.number)
    click_button "Reopen"
    page.should have_content("Note state changed to Reopened")
  end

end
