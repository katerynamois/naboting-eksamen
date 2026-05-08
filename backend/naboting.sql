-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Vært: localhost:3306
-- Genereringstid: 17. 04 2026 kl. 09:27:05
-- Serverversion: 5.7.24
-- PHP-version: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS naboting;
USE naboting;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `naboting`
--

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `accessories`
--

CREATE TABLE `accessories` (
  `accessory_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `accessories`
--

INSERT INTO `accessories` (`accessory_id`, `item_id`, `name`) VALUES
(1, 1, 'Oplader'),
(2, 1, 'Ekstra batteri'),
(3, 2, 'Pløkker');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `item_condition` varchar(50) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  `minimum_loan_period` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `items`
--

INSERT INTO `items` (`item_id`, `owner_id`, `title`, `brand`, `category`, `item_condition`, `quantity`, `minimum_loan_period`, `status`, `created_at`) VALUES
(1, 1, 'Boremaskine', 'Bosch', 'Værktøj', 'God', 1, 3, 'available', '2026-04-16 15:52:57'),
(2, 2, 'Telt', 'Outwell', 'Fritid', 'Meget god', 1, 2, 'available', '2026-04-16 15:52:57');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `item_images`
--

CREATE TABLE `item_images` (
  `image_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `is_primary` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `item_images`
--

INSERT INTO `item_images` (`image_id`, `item_id`, `image_url`, `is_primary`) VALUES
(1, 1, 'images/boremaskine.jpg', 1),
(2, 2, 'images/telt.jpg', 1);

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `loans`
--

CREATE TABLE `loans` (
  `loan_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `borrower_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `loans`
--

INSERT INTO `loans` (`loan_id`, `item_id`, `borrower_id`, `start_date`, `end_date`, `status`, `created_at`) VALUES
(1, 1, 2, '2026-04-16', '2026-04-20', 'active', '2026-04-16 15:53:25');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `user_type` varchar(50) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `users`
--

INSERT INTO `users` (`user_id`, `email`, `phone`, `password_hash`, `user_type`, `first_name`, `last_name`, `postal_code`, `created_at`) VALUES
(1, 'anna@example.com', '12345678', 'hash123', 'private', 'Anna', 'Jensen', '2630', '2026-04-16 15:52:33'),
(2, 'bo@example.com', '87654321', 'hash456', 'private', 'Bo', 'Nielsen', '4000', '2026-04-16 15:52:33');

--
-- Begrænsninger for dumpede tabeller
--

--
-- Indeks for tabel `accessories`
--
ALTER TABLE `accessories`
  ADD PRIMARY KEY (`accessory_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indeks for tabel `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indeks for tabel `item_images`
--
ALTER TABLE `item_images`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indeks for tabel `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`loan_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `borrower_id` (`borrower_id`);

--
-- Indeks for tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Brug ikke AUTO_INCREMENT for slettede tabeller
--

--
-- Tilføj AUTO_INCREMENT i tabel `accessories`
--
ALTER TABLE `accessories`
  MODIFY `accessory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tilføj AUTO_INCREMENT i tabel `items`
--
ALTER TABLE `items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tilføj AUTO_INCREMENT i tabel `item_images`
--
ALTER TABLE `item_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tilføj AUTO_INCREMENT i tabel `loans`
--
ALTER TABLE `loans`
  MODIFY `loan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tilføj AUTO_INCREMENT i tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Begrænsninger for dumpede tabeller
--

--
-- Begrænsninger for tabel `accessories`
--
ALTER TABLE `accessories`
  ADD CONSTRAINT `accessories_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Begrænsninger for tabel `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`);

--
-- Begrænsninger for tabel `item_images`
--
ALTER TABLE `item_images`
  ADD CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Begrænsninger for tabel `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  ADD CONSTRAINT `loans_ibfk_2` FOREIGN KEY (`borrower_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
