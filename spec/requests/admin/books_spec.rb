require "support/admin_shared"

RSpec.describe Admin::BooksController, :admin, type: :controller do
  let(:book){create(:book)}
  let(:book_params){attributes_for(:book)}

  shared_examples "populate book" do
    it "assigns the requested book to @book" do
      expect(assigns(:book)).to eq book
    end
  end

  describe "GET #index" do
    before do
      create_list(:book_full_info, 2)
      get :index
    end

    it "populates array of Book to @books" do
      expected = Book.includes_info.available.newest
      expect(assigns(:books)).to match expected.to_a
    end

    it "renders :index template" do
      should render_template :index
    end
  end

  describe "GET #show" do
    context "when book is not found" do
      before do
        get :show, params: {id: -1}
      end

      include_examples "invalid item", :book
    end

    context "when book is found" do
      before do
        get :show, params: {id: book.id}
      end

      include_examples "populate book"

      it "assigns @tab_id to :book_detail" do
        expect(assigns(:tab_id)).to eq :book_detail
      end

      it "renders the :tab_detail template" do
        should render_template :tab_detail
      end
    end
  end

  describe "GET #new" do
    before do
      get :new
    end

    it "assigns @book to new Book" do
      expect(assigns(:book)).to be_a_clone_of Book.new
    end

    it "renders the :edit template" do
      should render_template :edit
    end
  end

  describe "GET #edit" do
    before do
      get :edit, params: {id: book.id}
    end

    context "when book is available" do
      include_examples "populate book"

      it "renders the :edit template" do
        should render_template :edit
      end
    end

    context "when book is deleted" do
      let(:book){create(:book, is_active: false)}
      include_examples "invalid item", :book
    end
  end

  describe "GET #amend_edit" do
    before do
      get :amend_edit, params: {id: book.id}
    end

    include_examples "populate book"

    it "renders the :amend_edit template" do
      should render_template :amend_edit
    end
  end

  describe "POST #create" do
    context "when params are valid" do
      before do
        post :create, params: {book: book_params}
      end

      it "assigns the new Book created from parameters to @book" do
        expect(assigns(:book)).to be_a_clone_of Book.new book_params
      end

      it "saves the book to database" do
        expect(assigns(:book)).to be_persisted
      end

      include_examples "set flash", :success, :create_success, name: I18n.t("books._name")

      it "redirects to update publisher, genres and authors page" do
        should redirect_to amend_admin_book_path(assigns(:book))
      end
    end

    context "when params are not valid" do
      before do |ex|
        post :create, params: {
          book: book_params.merge({amount: -1, title: nil}),
          format: ex.metadata[:turbo] ? :turbo_stream : :html
        }
      end

      include_examples "check errors", :book, "@book", :title, :amount

      context "with turbo_stream format", :turbo do
        it "renders the :form_fail partial" do
          should render_template "admin/shared/_form_fail"
        end
      end

      context "with html format" do
        it "renders the :edit template" do
          should render_template :edit
        end
      end
    end
  end

  describe "PATCH #update" do
    before do |ex|
      patch :update, params: {
        id: book.id,
        book: book_params,
        skip: ex.metadata[:params_skip]
      }
    end

    context "when skip this page", :params_skip do
      it "redirects to update publisher, genres and authors page" do
        redirect_to amend_admin_book_path(book)
      end
    end

    context "when params are valid" do
      it "changes the book attributes" do
        expect(assigns(:book).reload.attributes).to include(book_params.transform_keys(&:to_s))
      end

      include_examples "set flash", :success, :update_success, name: I18n.t("books._name")

      it "redirects to update publisher, genres and authors page" do
        should redirect_to amend_admin_book_path(book)
      end
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
          book: relation_book_params,
          skip: ex.metadata[:params_skip]
        }
      end
    end

    context "when skip this page", :params_skip do
      it "redirects to :show page" do
        redirect_to admin_book_path(book)
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

      include_examples "set flash", :success, :update_success, name: I18n.t("books._name")

      it "redirects to show page" do
        should redirect_to admin_book_path(book)
      end
    end

    context "when params are not valid", :custom_request do
      before do
        patch :amend, params: {
          id: book.id,
          book: relation_book_params.merge({genres: (genres.pluck(:id) << -1)})
        }
      end

      include_examples "check errors", :book, "@book", :genre

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
    context "when the book has some copies borrowed" do
      let(:book) {create(:book, :borrowable_book)}
      before do
        delete :destroy, params: {id: book.id, format: :turbo_stream}
      end

      include_examples "set flash", :error, :delete_book_fail_borrowed, now: true

      it "render :notify partial" do
        should render_template(partial: "admin/shared/_notify")
      end
    end

    context "when the book has not been borrowed yet" do
      context "when update :is_active successfully" do
        before do
          delete :destroy, params: {id: book.id, format: :turbo_stream}
        end
        include_examples "set flash", :success, :delete_success, name: I18n.t("books._name")
      end

      it "redirects to books list page" do
        redirect_to admin_books_path
      end
    end
  end
end
