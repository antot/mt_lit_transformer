ABOUT
-----

This repository contains supplementary material for the publication:

Toral, A., Oliver, A., & Ribas Ballestín, P. (2020). Machine Translation of Novels in the Age of Transformer. In J. Porsiel (Ed.), Maschinelle Übersetzung für Übersetzungsprofis (pp. 276-295). BDÜ Fachverlag.


CONTENTS
--------

- **preference/** data from the preference-based human evaluation (section 5.1 in the paper). Script howto_preference.sh runs the evaluation. Rankings exported from Appraise are provided in xml and csv formats. In the files "t1" corresponds to the human translation, "t2" to the in-house RNN-based system and "t3" to the in-house Transformer-based system.
- **post_editing/** data from the post-editing experiment (section 5.2). There is one csv file per machine translation system (Google Translate, in-house RNN-based and in-house Transformer-based). In each csv file the columns correspond to: 1) sentence ID, 2) source sentence, 3) MT output, 4) post-edition, 5) comment about the error(s) fixed.
