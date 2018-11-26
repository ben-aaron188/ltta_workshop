## Linguistic temporal trajectory analysis

This is the companion website for the "Linguistic temporal trajectory analysis" workshop that we teach at the [2018 European Symposium Series on Societal Challenges
in Computational Social Science](http://symposium.computationalsocialscience.eu/2018/). The workshop will provide participants with an overview of techniques and existing works related to linguistic temporal trajectory analysis in R.

We welcome students and researchers from all disciplines working with text data that are interested in applying computational concepts in the social sciences (e.g., Psychology, Criminology, Computer Science, Linguistics, Digital Humanities, Political Science, etc.).

_(this website is currently updated for the workshop)_

### What is it?

This workshop focuses on the quantitative analysis of text data using the concept of *linguistic temporal trajectory analysis (LTTA)*. LTTA aims to study how the use of language develops over time by continuously analysing semantic properties of temporal representations of language. Specifically, the temporal development can be studied (i) on the forum-level (i.e., how does the language used on whole platforms or sub-forums change over time?), (ii) on the user-level (i.e., how do individual users change their language over time?), and (iii) on the intra-textual level (i.e., how do text properties change as a function of narrative progression?). In doing so, LTTA combines computational linguistics with statistical modeling (e.g., time series analysis) to provide a new base for understanding social and behavioral phenomena in text data. 

LTTA's continuous and dynamic approach to studying linguistic data can help shed light on dynamic processes in linguistic data that are not captured by static approaches. LTTA is particularly promising for research areas where relevant constructs might be hidden (e.g., hidden advertisement in YouTube vlogs and detecting embedded deception in statements), or where forecasting models could help mitigate or prevent phase transitions (e.g., in the development of radical language).

We will outline the idea behind LTTA, how to implement it in R, and discuss the assumptions and limitaions of the method.

### Preliminary schedule of the workshop

Note: this workshop consists of one **WORKSHOP + TUTORIAL** part (in the morning) and a **PAPER HACKATHON** (after the lunch break).

The preliminary workshop schedule is as follows:

| WORKSHOP + TUTORIAL                      | (morning)         |
| :--------------------------------------- | :---------------- |
| **Introduction to linguistic temporal trajectory analysis** | **09:30 - 10:30** |
| Rationale, the aim of the method, differences to existing approaches (e.g., simple sentiment analysis), levels of analysis  (trajectory of language use over time vs. dynamic intratextual linguistic analysis),  extensions: unsupervised (non-)hierarchical clustering of temporal patterns, supervised machine learning with temporal patterns, breakpoint estimation of non-stationary linguistic time series data. | Mini-lectures     |
| **Examples of linguistic temporal trajectory analysis** | **10:30 - 11:15** |
| Linguistic trajectories of far-right extremists,  intratextual sentiment analysis of narrative styles of YouTube vloggers, narrative trajectories in TED talks, emotional arcs of stories,  Intratextual sentiment analysis of lone-actor terrorists’ manifestos | Case-studies      |
| **Linguistic trajectory analysis in R**  | **11:30 - 13:00** |
| Running LTTA on simple simulated data (using a plenary walk-through code example),  using LTTA on real data reproducing the analysis of our "narrative styles of YouTube vlogs" paper (individually or in teams under the guidance of the organizers) | Tutorial          |
|                                          |                   |
| **LUNCH BREAK**                          | **13:00 - 14:30** |
|                                          |                   |
| **PAPER HACKATHON**                      | **14:30 - 18:00** |

#### Paper hackathon

Dataset provided uniquely for this session:

-	Transcripts of all vlogs uploaded to YouTube by specific YouTubers.
 - Columns: vlogger ID, vlog transcript, vlog view count, upvotes, downvotes, vlog posting date.
 - Each row represents one vlog.
 - Features (extracted before due to time constraints): part-of-speech tags, psycholinguistic variables (e.g., from the LIWC), ngrams, sentiment shapes

In line with this year's EuroCSS theme "Bias and discrimination", we have created a dataset of transcripts of 'left-wing' and 'right-wing' news channels. The dataset is introduced in the morning session of the workshop.

Possible research questions:

 - Is there a common sentiment trajectory of channels on the left and right?
 - Are some trajectories more 'successful' (e.g. view count, upvotes, downvotes) than others?
 - Does the linguistic trajectory evolution differ between the two political spectra?

Format:

-	All workshop participants are provided with the dataset (GitHub repo and readme)
 - All participants have access to a shared Google Document for the paper
 - Participants and organizers brainstorm possible approaches
 - Work on the paper (e.g., distributed into introduction, dataset description, method, results, discussion)
 - All participants are co-authors of the paper (to be determined at random) with a detailed appendix on author contributions.
 - The workshop ends with a (nearly) ready draft of the paper which is posted on arXiv in its final form and jointly submitted to the _Journal of Computational Social Science_.


### Prerequisites

Participants should have some basic knowledge of the _R_ or _python_ programming language. The workshop will focus on R but the transition from python is relatively straightforward (esp. with pandas).

### Organisers

|      ![Bennett](./img/bennett.jpg)       |     ![Isabelle](./img/isabelle.jpg)      |          ![Max](./img/max.jpg)           |
| :--------------------------------------: | :--------------------------------------: | :--------------------------------------: |
| [Bennett Kleinberg](https://bkleinberg.net) | [Isabelle van der Vegt](https://twitter.com/Isabellevdv) |  [Maximilian Mozes](http://mmozes.net)   |
| Assistant Professor in Data Science (University College London) | PhD student (University College London)  | BSc student (Technical University of Munich) |

-----



