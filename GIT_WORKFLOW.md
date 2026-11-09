# How I make changes to this project

`main` holds the latest **reviewed** version. Every change goes on its own branch first, then into `main` through a pull request (PR) that I review before merging.

```
main ──●──────────────●──  (reviewed version)
        \            /
         ●──●──●────     my branch: commits → push → pull request → review → merge
```

**Words I use**

| Word | Meaning |
|---|---|
| Commit | A saved snapshot of my changes, with a short message saying what changed |
| Branch | A separate copy of the project where I can change things without touching `main` |
| Push | Send my commits from my laptop to GitHub |
| Pull | Bring the latest version from GitHub down to my laptop |
| Pull request (PR) | A page on GitHub that shows my branch's changes and asks to merge them into `main` |
| Merge | Add a branch's reviewed changes into `main` |

---

## Option A: in the browser (what I already know)

1. Open the file on GitHub and click the **pencil** (Edit).
2. Make the change.
3. Click **Commit changes…**, write a short message in my own words, and choose **"Create a new branch for this commit and start a pull request"**. Give the branch a short name, e.g. `add-specialty-rates`.
4. On the PR page, write what changed and why, then click **Create pull request**.
5. **Review:** open the **Files changed** tab. Red lines were removed, green lines were added. Check every number against my DB Browser results.
6. If it's right, click **Merge pull request** → **Confirm merge**. `main` now has the change.

## Option B: on my Mac with the command line

**One-time setup**

```bash
git clone https://github.com/NandiniB216/medical-appointments-no-show-analysis.git
cd medical-appointments-no-show-analysis
```

**Every time I change something**

```bash
git checkout main          # go to main
git pull                   # get the latest version from GitHub
git checkout -b add-specialty-rates   # make a new branch and move onto it

# ...edit files (e.g. paste new queries into sql/project01.sql)...

git status                 # see which files changed
git diff                   # see exactly what changed
git add sql/project01.sql  # choose the files to save
git commit -m "Add no-show rate by specialty"
git push -u origin add-specialty-rates   # send the branch to GitHub
```

Then open the repository on GitHub. A yellow bar offers **Compare & pull request**: click it, describe the change, and create the PR. Review and merge as in steps 5–6 above.

**After merging**

```bash
git checkout main
git pull                   # my laptop now matches GitHub
```

---

## My checklist before merging

- [ ] Every new number comes from a query I actually ran, and the parts add up to the total.
- [ ] A concept moves to ✅ in the README's SQL progress table only after a **solo test**.
- [ ] New findings are marked as preliminary until they're checked.
- [ ] Guided or tutor-given queries are labelled as such.
- [ ] No database file, personal details, work information or passwords are in the change.

**Good commit messages** say what changed, in a few words: `Add no-show rate by specialty`, `Fix age group count`, `Update SQL progress after solo test`.

<sub>Drafted with AI help (Claude) as a reference while I learn Git.</sub>
