create database HKmoolya;
use HKmoolya;
create table tUser(user_id INT PRIMARY KEY AUTO_INCREMENT, username VARCHAR(50) UNIQUE NOT NULL,
					email VARCHAR(100) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL,
                    full_name VARCHAR(100), date_of_birth DATE,phone VARCHAR(20),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,last_login TIMESTAMP);

create table tFriends(friendship_id INT PRIMARY KEY AUTO_INCREMENT,
					   user_id INT NOT NULL,
                       FOREIGN KEY (user_id) REFERENCES tUser(user_id) ON DELETE CASCADE,
					   friend_id INT NOT NULL,
					   FOREIGN KEY (friend_id) REFERENCES tUser(user_id) ON DELETE CASCADE,
                       status ENUM('pending', 'accepted', 'blocked'),created_at TIMESTAMP);
                       
create table tPosts( post_id INT PRIMARY KEY AUTO_INCREMENT,user_id INT NOT NULL,
					FOREIGN KEY(user_id) REFERENCES tUser(User_id) ON DELETE CASCADE,
                    content TEXT NOT NULL,image_url VARCHAR(255),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    likes_count INT DEFAULT 0);
                    
create table tComments(comment_id INT PRIMARY KEY AUTO_INCREMENT,
						post_id INT NOT NULL,
                        FOREIGN KEY(post_id) REFERENCES tPosts(post_id) ON DELETE CASCADE,
                        user_id INT NOT NULL,
						FOREIGN KEY(user_id) REFERENCES tUser(User_id) ON DELETE CASCADE,
						comment_text TEXT NOT NULL,
                        created_at TIMESTAMP);




-- EXAMPLE DATA FOR UNDERSTANDING
INSERT INTO tUser (username, email, password_hash, full_name, date_of_birth, phone)
VALUES
('HARI', 'hari@gmail.com', 'HK123', 'HARI KRISHNA', '2004-03-25', '9876543210'),
('KRISHNA', 'krishna@yahoo.com', 'KRISHNA577', 'SHRI KRISHNA', '1997-08-21', '9876501234'),
('SHYAM', 'shyam@outlook.com', 'SHYAM@2011', 'SHYAM', '1993-11-03', '9898989898'),
('RAM', 'ram@gmail.com', 'RAM246', 'RAM', '1998-02-15', '9765432190'),
('ravi_kumar', 'ravi@example.com', 'RAVI143', 'Ravi Kumar', '1996-09-09', '9999999999');


INSERT INTO tFriends (user_id, friend_id, status)
VALUES
(1, 2, 'accepted'),   
(1, 3, 'pending'),    
(2, 4, 'accepted'),   
(3, 5, 'accepted'),  
(4, 5, 'blocked'); 

INSERT INTO tPosts (user_id, content, image_url, likes_count)
VALUES
(1, 'GOOD MORNING, HAVE A GOOD DAY', NULL, 15),
(2, 'AT RAM MANDIR TO TAKE BLESSINGS ', 'images/RAM_MANDIR.jpg', 25),
(3, 'STARTED MY JOURNEY WITH MOOLYA', NULL, 8),
(5, 'ON A HOLIDAY', 'images/BEACH.jpg', 18);


INSERT INTO tComments (post_id, user_id, comment_text)
VALUES
(1, 2, 'WISHING U THE SAME'),
(1, 3, 'POSITIVE VIBES....'),
(2, 1, 'SUPERB TEMPLE BROO'),
(3, 4, 'ALL THE BEST BRO, HOPE U WILL GET BEST VIBES'),
(5, 2, 'HAPPY JOURNEY RAVI..');


-- Fetch all information for a user given their username

SELECT * FROM tUser
WHERE username = 'HARI';

-- Get all posts by a specific user, sorted by latest first
SELECT 
    p.post_id,
    u.username,
    p.content,
    p.image_url,
    p.likes_count,
    p.created_at
FROM tPosts as p
JOIN tUser as u ON p.user_id = u.user_id
WHERE u.username = 'KRISHNA'
ORDER BY p.created_at DESC;

-- Find all friends of a user with 'accepted' status

SELECT 
    f.friendship_id,
    u.username AS user_name,
    u2.username AS friend_name,
    f.status,
    f.created_at
FROM tFriends f
JOIN tUser u ON f.user_id = u.user_id
JOIN tUser u2 ON f.friend_id = u2.user_id
WHERE u.username = 'HARI' AND f.status='accepted';

-- Get all posts with more than 10 likes
SELECT 
    p.post_id,
    p.user_id,
    u.username AS author,
    p.content,
    p.image_url,
    p.likes_count,
    p.created_at
FROM tPosts as p
JOIN tUser as u ON p.user_id = u.user_id
WHERE p.likes_count > 10
ORDER BY p.likes_count DESC;

-- Find users who have not posted in the last 30 days

SELECT 
    u.user_id,
    u.username
FROM tUser as u
LEFT JOIN tPosts as p 
    ON u.user_id = p.user_id 
    AND p.created_at >= NOW() - INTERVAL 30 DAY
WHERE p.post_id IS NULL;


-- Calculate average number of posts per user
SELECT 
    COUNT(p.post_id) AS total_posts,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(p.post_id) / COUNT(DISTINCT u.user_id) AS avg_posts_per_user
FROM tUseras as u
LEFT JOIN tPosts as p ON u.user_id = p.user_id;

-- Find the top 5 users with most friends

SELECT u.username, COUNT(*) AS total_friends
	FROM tFriends as tf
	JOIN tUser as u 
		ON u.user_id = tf.user_id OR u.user_id = tf.friend_id
	WHERE tf.status = 'accepted'
	GROUP BY u.user_id, u.username
	ORDER BY total_friends DESC
	LIMIT 5;
    
-- Get all comments for a specific post along with user details

SELECT c.comment_id, u.user_id, u.username, u.full_name, u.email, c.comment_text, c.created_at
FROM tComments as c
JOIN tUser as u ON c.user_id = u.user_id
WHERE c.post_id = 2
ORDER BY c.created_at ASC;

-- Find mutual friends between two users

SELECT 
    u.username AS mutual_friend
FROM tfriends f1
JOIN tfriends f2 ON f1.friend_id = f2.friend_id
JOIN tUser u ON f1.friend_id = u.user_id
WHERE f1.user_id = (SELECT user_id FROM tUser WHERE username = 'HARI')
  AND f2.user_id = (SELECT user_id FROM tUser WHERE username = 'KRISHNA')
  AND f1.status = 'accepted'
  AND f2.status= 'accepted';


-- Delete all posts older than 1 year
SET SQL_SAFE_UPDATES = 0;
DELETE FROM tPosts
WHERE created_at < (NOW() - INTERVAL 1 YEAR);



