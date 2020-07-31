from itertools import combinations
group1 = [16,17,18]
group2 = [20,21]
group3 = []
siblings = group1 + group2 + group3
for (s1, s2) in combinations(siblings, 2):
  are_full_siblings = (s1 in group1 and s2 in group1) or (s1 in group2 and s2 in group2) or (s1 in group3 and s2 in group3)
  weight = are_full_siblings and 1.0 or 0.5
  print(f'{s1},{s2},{weight}')