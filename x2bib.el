;;; x2bib.el --- Bibliography conversion to Bibtex

;;; Header:

;;; Commentary:

;; This module is more for my convenience to convert bibliography files to bibtex.  This can be done at the command line, for example, but I want to do it in Emacs.  There are a few scenarios where this happens.
;; 1. Someone sends me a non-Bibtex file (Endnote, etc...)
;; 2. From some online search I select many references and there is no export to Bibtex option, e.g. from Web of Science.

;; This code is mostly wrappers around the command line utilities at http://sourceforge.net/p/bibutils/home/Bibutils.

;; Here are the commands that are available.

;; bib2xml	convert BibTeX to MODS XML intermediate
;; biblatex2xml	convert BibLaTeX to MODS XML intermediate
;; copac2xml	convert COPAC format references to MODS XML intermediate
;; end2xml	convert EndNote (Refer format) to MODS XML intermediate
;; endx2xml	convert EndNote XML to MODS XML intermediate
;; isi2xml	convert ISI web of science to MODS XML intermediate
;; med2xml	convert Pubmed XML references to MODS XML intermediate
;; modsclean	a MODS to MODS converter for testing puposes mostly
;; ris2xml	convert RIS format to MODS XML intermediate
;; xml2ads	convert MODS XML intermediate into Smithsonian Astrophysical Observatory (SAO)/National Aeronautics and Space Administration (NASA) Astrophyics Data System or ADS reference format (converter submitted by Richard Mathar)
;; xml2bib	convert MODS XML intermediate into BibTeX
;; xml2end	convert MODS XML intermediate into format for EndNote
;; xml2isi	convert MODS XML intermediate to ISI format
;; xml2ris	convert MODS XML intermediate into RIS format
;; xml2wordbib	convert MODS XML intermediate into Word 2007 bibliography format


;;; Code:

;; ** RIS to bibtex
;; RIS can be pretty easily exported from Endnote. Here is a function to read an RIS file and convert it to bibtex which is inserted at point. Note that there is often other output from the commands. We try to comment them out here, but you should probably inspect the entries, and do other bibtex file compliance checks.

(defun ris2bib (risfile &optional verbose)
  "Convert RISFILE to bibtex and insert at point.
Without a prefix arg, stderr is diverted."
  (interactive
   (list (read-file-name "RIS file:")
         (prefix-numeric-value current-prefix-arg)))
  (let ((result (shell-command-to-string
                 (concat
                  (format
                   "ris2xml %s | xml2bib -w"
                   risfile)
                  (unless verbose " 2> /dev/null")))))
    ;; make some lines into comments.
    (setq result (replace-regexp-in-string
                  "^xml2bib:"
                  "% xml2bib:"
                  result))
    (setq result (replace-regexp-in-string
                  "^ris2xml:"
                  "% ris2xml"
                  result))
    (setq result (replace-regexp-in-string
                  "^	Defaulting"
                  "%	Defaulting"
                  result))
    (insert result)))

;; ** Pubmed XML to bibtex
;; In http://www.ncbi.nlm.nih.gov/pubmed/ you can select entries, and then send them to a file. If you choose Pubmed XML as the format, then you can use this function to convert it to bibtex.

(defun medxml2bib (medfile &optional verbose)
  "Convert MEDFILE (in Pubmed xml) to bibtex and insert at point.
Without a prefix arg, stderr is diverted."
  (interactive
   (list (read-file-name "MED file:")
         (prefix-numeric-value current-prefix-arg)))
  (let ((result (shell-command-to-string
                 (concat
                  (format
                   "med2xml %s | xml2bib -w"
                   medfile)
                  (unless verbose " 2> /dev/null")))))
    ;; make some lines into comments.
    (setq result (replace-regexp-in-string
                  "^xml2bib:"
                  "% xml2bib:"
                  result))
    (setq result (replace-regexp-in-string
                  "^med2xml:"
                  "% med2xml"
                  result))
    (setq result (replace-regexp-in-string
                  "^	Defaulting"
                  "%	Defaulting"
                  result))
    (insert result)))

;; ** Clean up all the entries

;; Finally, after you put the new entries in, you probably need to do some clean up actions. This little function does that.

(defun clean-entries ()
  "Map over bibtex entries and clean them."
  (interactive)
  (bibtex-map-entries
   (lambda (a b c)
     (ignore-errors
       (org-ref-clean-bibtex-entry)))))

(provide 'x2bib)

;;; x2bib.el ends here
