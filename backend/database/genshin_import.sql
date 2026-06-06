-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 06, 2026 at 07:05 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `genshin_import`
--

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` enum('Weapon','Artifact') NOT NULL,
  `type` varchar(50) NOT NULL,
  `stat` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `image` varchar(255) DEFAULT NULL,
  `price` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `name`, `category`, `type`, `stat`, `description`, `stock`, `image`, `price`) VALUES
(1, 'Wolf\'s Gravestone', 'Weapon', 'Claymore', '', 'The Knight of Boreas\' journey ended at the city of Barbatos. Wandering souls attract each other, boundless freedom begets only anxiety', 3, '1780576515638.png', 100000.00),
(3, 'Gladiator\'s Destiny', 'Artifact', 'Feather', '', 'The end had finally come for the triumphant gladiator. The young challenger paid her final homage to the gladiator', 7, '1780577643518.png', 70000.00);

-- --------------------------------------------------------

--
-- Table structure for table `topup`
--

CREATE TABLE `topup` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `mora_amount` int(11) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `topup`
--

INSERT INTO `topup` (`id`, `user_id`, `mora_amount`, `price`, `created_at`) VALUES
(1, 3, 10000, 100000.00, '2026-06-05 05:23:39'),
(2, 3, 100000, 1000000.00, '2026-06-05 05:34:49'),
(3, 3, 10000, 100000.00, '2026-06-05 05:42:30'),
(4, 3, 10000, 100000.00, '2026-06-05 05:53:16'),
(5, 3, 10000, 100000.00, '2026-06-05 06:13:02'),
(6, 3, 10000, 100000.00, '2026-06-05 06:17:45'),
(7, 3, 10000, 100000.00, '2026-06-05 06:44:38'),
(8, 3, 10000, 100000.00, '2026-06-05 06:52:45'),
(9, 3, 10000, 100000.00, '2026-06-05 07:10:54'),
(10, 3, 10000, 100000.00, '2026-06-05 07:15:39'),
(11, 3, 10000, 100000.00, '2026-06-05 07:22:53'),
(12, 3, 10000, 100000.00, '2026-06-05 07:26:03'),
(13, 3, 10000, 100000.00, '2026-06-05 07:45:00'),
(14, 3, 10000, 100000.00, '2026-06-05 07:49:43'),
(15, 3, 10000, 100000.00, '2026-06-05 08:10:35'),
(16, 3, 10000, 100000.00, '2026-06-05 08:10:44'),
(17, 4, 10000, 100000.00, '2026-06-05 11:04:00'),
(18, 4, 50000, 500000.00, '2026-06-05 11:04:21'),
(19, 4, 50000, 500000.00, '2026-06-05 11:04:23'),
(20, 5, 1000000, 10000000.00, '2026-06-06 04:04:07'),
(21, 1, 10000, 100000.00, '2026-06-06 04:33:48'),
(22, 5, 10000, 100000.00, '2026-06-06 04:34:04');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `item_image` varchar(255) DEFAULT NULL,
  `item_type` varchar(50) DEFAULT '',
  `quantity` int(11) NOT NULL,
  `total_price` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `item_id`, `item_name`, `item_image`, `item_type`, `quantity`, `total_price`, `created_at`) VALUES
(1, 3, 1, 'Wolf\'s Gravestone', '1780576515638.png', 'Claymore', 1, 100000.00, '2026-06-05 08:10:58'),
(2, 3, 1, 'Wolf\'s Gravestone', '1780576515638.png', 'Claymore', 1, 100000.00, '2026-06-05 08:28:41'),
(3, 4, 1, 'Wolf\'s Gravestone', '1780576515638.png', 'Claymore', 1, 100000.00, '2026-06-05 11:04:31'),
(4, 5, 1, 'Wolf\'s Gravestone', '1780576515638.png', 'Claymore', 1, 100000.00, '2026-06-06 04:04:31');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `mora` decimal(15,2) DEFAULT 0.00,
  `profile_picture` varchar(255) DEFAULT NULL,
  `cover_photo` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `mora`, `profile_picture`, `cover_photo`, `bio`, `token`) VALUES
(1, 'Admin ganteng', 'admin@genshin.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 10000.00, '1780636939904.jpg', '1780636939924.jpg', 'idk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJhZG1pbkBnZW5zaGluLmNvbSIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc4MDcyMTY5MSwiZXhwIjoxNzgxMzI2NDkxfQ.9k1sGb0MDobzcG6a6mk5e4qD33W_9YsSGkRCmm05BU4'),
(3, 'user1', 'user1@gmail.com', '$2b$10$HnK1BwD5afMkoaDV6x7.Vu3/.ArMo0MxgrX3aKptz4BseHb9BrjF2', 'user', 50000.00, NULL, NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiZW1haWwiOiJ1c2VyMUBnbWFpbC5jb20iLCJyb2xlIjoidXNlciIsImlhdCI6MTc4MDcyMTQyMSwiZXhwIjoxNzgxMzI2MjIxfQ.sQ16Pm4pF9y81DqYc1tOqf8SykgBO90RQGyn5uu2lFw'),
(4, 'JNP', 'jasonnathanielprijatno@gmail.com', '', 'user', 10000.00, NULL, NULL, 'hhhh', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NCwiZW1haWwiOiJqYXNvbm5hdGhhbmllbHByaWphdG5vQGdtYWlsLmNvbSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzgwNjYwNTM2LCJleHAiOjE3ODEyNjUzMzZ9.3nGznSyhby_cR3OOWCsAsVIrxr69YH7ubvPTyGUsXgM'),
(5, 'Yupri ando', 'yupriandoo@gmail.com', '', 'user', 910000.00, NULL, NULL, '', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwiZW1haWwiOiJ5dXByaWFuZG9vQGdtYWlsLmNvbSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzgwNzIxODY4LCJleHAiOjE3ODEzMjY2Njh9.X_qGxK27x2APlCz6gpF_uJa4owds30ASW8jfBG2zZCc');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `topup`
--
ALTER TABLE `topup`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `topup`
--
ALTER TABLE `topup`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `topup`
--
ALTER TABLE `topup`
  ADD CONSTRAINT `topup_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
