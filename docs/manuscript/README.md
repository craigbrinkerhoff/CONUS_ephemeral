## Knitting manuscript

The manuscript that accompanies this analysis is written in `RMarkdown` and automatically pulls all results, figures, references, and summary statistics from the pipeline into the paper for reproducibility. All other files in this directory are necessary for correctly formatting the word document that is knitted. Use the below command:

```
R
render('docs/manuscript/CONUS_ephemeral.Rmd')
```

This knits a single document containing both the manuscript and its supporting information.

Note that Fig. 1 needs to be manually assembled in Adobe Illustrator to include the insets conceptually describing the model.