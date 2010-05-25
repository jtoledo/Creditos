class PdfController < ApplicationController
def index

  require "pdf\/writer"

pdf = PDF::Writer.new
pdf.select_font "Times-Roman"
pdf.text "Hello, Ruby.", :font_size => 72, :justification => :center

pdf.save_as("prueba.pdf")

end
end
