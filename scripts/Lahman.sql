--1. What range of years for baseball games played does the provided database cover?

SELECT 
MIN(yearid),
MAX(yearid)
FROM batting;

---Answer: 1871 to 2016


--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
MIN(height) AS shortest_height,
namefirst,
namelast,
namegiven,
playerid
FROM(SELECT playerid,
	  namefirst,
	  namelast,
	  namegiven,
	  height
	FROM people) AS subquery
GROUP BY namefirst, namelast, namegiven, playerid
ORDER BY shortest_height
LIMIT 1;

--Answer: Eddie Gaedel, Edwrd Carl

SELECT 
a.g_all,
p.namefirst,
p.namelast,
p.namegiven,
p.playerid
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
WHERE p.playerid = 'gaedeed01';

-- played in 1 game

SELECT 
a.g_all,
t.name,
p.namegiven,
p.playerid
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS T
ON a.teamid = t.teamid
ORDER BY p.height;

 -- Team = St. Louis Browns


--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT 
p.namefirst,
p.namelast,
p.playerid,
SUM(s.salary) AS totalsalary
FROM people AS P
LEFT JOIN salaries as s
USING (playerid)
WHERE playerid IN (SELECT  playerid
		  FROM collegeplaying
		  WHERE schoolid = 'vandy')
GROUP BY p.namefirst,
	     p.namelast,
	     p.playerid
HAVING SUM(s.salary) IS NOT NULL
ORDER BY totalsalary DESC;

--Answer : David Price

--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
DISTINCT playerid,
yearid,
pos,
CASE WHEN pos = 'OF' THEN 'Outfield'
     WHEN pos = 'SS'
	          OR pos = '1B'
			  OR pos = '2B'
			  OR pos = '3B' THEN 'Infield'
			  ELSE 'Battery' END AS position
FROM fielding;			  

SELECT
	SUM(po) AS total_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS'
			OR pos = '1B'
			OR pos = '2B'
			OR pos = '3B' THEN 'Infield'
		ELSE 'Battery' END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

--Answer Battery (41,424) Infield (58,934), Outfield (29,560)


--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
	ROUND((ROUND(AVG(so),2) / (SUM(g) / 2)), 2) AS avgsopg,
	ROUND((ROUND(AVG(hr),2) / (SUM(g) / 2)), 2) AS avghrpg,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		 WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' 
		 END AS decade
		 FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;


--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT
	DISTINCT b.playerid,
	p.namefirst,
	p.namelast,
	CAST(b.sb AS numeric) AS stolenbases,
	CAST(b.cs AS numeric) AS caughtstealing,
	CAST(b.sb AS numeric) + CAST(b.cs AS numeric) AS attempts,
	ROUND((CAST(b.sb AS numeric) / (CAST(b.sb AS numeric) + CAST(b.cs AS numeric))), 2) AS success
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
WHERE b.yearid = '2016'
GROUP BY
	b.playerid,
	p.namefirst,
	p.namelast,
	b.sb,
	b.cs
HAVING CAST(sb AS numeric) + CAST(cs AS numeric) >= 20
ORDER BY success DESC;

-- Answer : Chris Owings, 91%


--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time? #COME BACK TO Q7 TO COMPLETE IT

SELECT
	DISTINCT name,
	yearid,
	wswin,
	w
FROM teams
WHERE yearid >= 1970
	AND wswin NOT LIKE 'Y'
ORDER BY w DESC;

--Answer : largest number of wins for a team is 116 by Seattle Mariners


--8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT
	p.park_name,
	h.team,
	ROUND((CAST(h.attendance AS numeric) / CAST(h.games AS numeric))) AS avg_att,
	h.games
FROM homegames AS h
LEFT JOIN parks AS p
ON h.park = p.park
WHERE h.year = 2016
GROUP BY
	p.park_name,
	h.team,
	h.games,
	h.attendance
HAVING games >= 10
ORDER BY avg_att DESC
LIMIT 5;

--Answer: Top 5 
--Dodger Stadium (Los Angeles Dodgers) at 45,720
--Busch Stadium III (St Louis Cardinals) at 42,525
--Rogers Center (Toronto Blue Jays) at 41,878
--AT&T Park (San Francisco Giants) at 41,546
--Wrigley Field (Chicago Cubs) at 39,906


SELECT
	p.park_name,
	h.team,
	ROUND((CAST(h.attendance AS numeric) / CAST(h.games AS numeric))) AS avg_att,
	h.games
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
WHERE h.year = 2016
GROUP BY
	p.park_name,
	h.team,
	h.games,
	h.attendance
HAVING games >= 10
ORDER BY avg_att ASC
LIMIT 5;

--Answer: Lowest 5

--9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--10.Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.





