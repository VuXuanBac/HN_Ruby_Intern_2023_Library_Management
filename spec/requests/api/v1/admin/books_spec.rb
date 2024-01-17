require "support/api_shared"

RSpec.describe API::V1::Admin::BooksController, :api_admin, type: :controller do
  let(:book){create(:book)}
  let(:book_params){attributes_for(:book)}
  let(:serialize_attributes){%w(id title description isbn amount available borrowed publish_date authors publisher genres last_update cover)}

  describe "GET #index" do
    before do
      create_list(:book_full_info, 2)
      get :index
    end

    include_examples "json collection", :book, 2
  end

  describe "GET #show" do
    context "when book is not found" do
      before do
        get :show, params: {id: -1}
      end
      include_examples "json message", :record_not_found, status: :not_found
    end

    context "when book is found" do
      before do
        get :show, params: {id: book.id}
      end

      include_examples "json object", :book
    end
  end

  describe "POST #create" do
    context "when params are valid" do
      before do
        post :create, params: {book: book_params}
      end

      it "saves the book to database" do
        expect(assigns(:book)).to be_persisted
      end

      include_examples "json object", :book
    end

    context "when params are not valid" do
      before do |ex|
        post :create, params: {
          book: book_params.merge({amount: -1, title: nil})
        }
      end

      include_examples "json errors", :book, :create
    end
  end

  describe "PATCH #update" do
    before do |ex|
      patch :update, params: {
        id: book.id,
        book: book_params
      }
    end

    context "when book is deleted" do
      let(:book){create(:book, is_active: false)}
      include_examples "json message", :record_not_found, status: :not_found
    end

    context "when params are valid" do
      it "changes the book attributes" do
        expect(assigns(:book).reload.attributes).to include(book_params.transform_keys(&:to_s))
      end

      include_examples "json object", :book
    end
  end

  describe "PATCH #amend" do
    let(:book){create(:book_full_info)}
    let(:publisher){create(:publisher)}
    let(:authors){create_list(:author, 3)}
    let(:genres){create_list(:genre, 2)}
    let(:relation_book_params) do
      {
        publisher: publisher.id,
        authors: authors.pluck(:id),
        genres: genres.pluck(:id)
      }
    end

    before do |ex|
      unless ex.metadata[:custom_request]
        patch :amend, params: {
          id: book.id,
          book: relation_book_params
        }
      end
    end

    context "when params are valid" do
      it "changes the publisher" do
        expect(assigns(:book).publisher_id).to eq(publisher.id)
      end

      it "changes the authors" do
        expect(assigns(:book).authors.pluck(:id)).to match_array(authors.pluck(:id))
      end

      context "with genres" do
        it "changes the genres" do
          expect(assigns(:book).genres.pluck(:id)).to match_array(genres.pluck(:id))
        end
      end

      context "without genres", :custom_request do
        before do
          patch :amend, params: {
            id: book.id,
            book: relation_book_params.except(:genres)
          }
        end
        it "keeps the genres" do
          expect(assigns(:book).genres.pluck(:id)).to match_array(book.genres.pluck(:id))
        end
      end

      include_examples "json object", :book
    end

  context "when params are not valid", :custom_request do
      before do
        patch :amend, params: {
          id: book.id,
          book: relation_book_params.merge({genres: (genres.pluck(:id) << -1)})
        }
      end

      include_examples "json errors", :book, :update

      it "keeps the publisher" do
        expect(assigns(:book).publisher_id).to eq(book.publisher.id)
      end

      it "keeps the authors" do
        expect(assigns(:book).authors.pluck(:id)).to match_array(book.authors.pluck(:id))
      end

      it "keeps the genres" do
        expect(assigns(:book).genres.pluck(:id)).to match_array(book.genres.pluck(:id))
      end
    end
  end

  describe "DELETE #destroy" do
    before do |ex|
      delete :destroy, params: {id: book.id}
    end

    context "when the book has some copies borrowed" do
      let(:book) {create(:book, :borrowable_book)}

      include_examples "json message", :delete_book_fail_borrowed
    end

    context "when the book has not been borrowed yet" do
      include_examples "json object", :book
    end
  end
end
