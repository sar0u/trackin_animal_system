package com.hbtech.cheptel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class CheptelBackendApplication {
	public static void main(String[] args) {
		SpringApplication.run(CheptelBackendApplication.class, args);
	}
}

