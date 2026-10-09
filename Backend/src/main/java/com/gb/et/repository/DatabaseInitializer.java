package com.gb.et.repository;

import com.gb.et.models.Organization;
import com.gb.et.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    @Autowired
    private OrganizationRepository organizationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${app.seed.username:}")
    private String seedUsername;

    @Value("${app.seed.password:}")
    private String seedPassword;

    @Override
    public void run(String... args) throws Exception {
        // Ensure 'default' organization exists
        Optional<Organization> defaultOrgOptional = organizationRepository.findByName("default");
        Organization defaultOrg;
        if (!defaultOrgOptional.isPresent()) {
            defaultOrg = new Organization();
            defaultOrg.setName("default");
            defaultOrg = organizationRepository.save(defaultOrg);
        } else {
            defaultOrg = defaultOrgOptional.get();
        }

        // Ensure 'anonymous' organization exists
        Optional<Organization> anonymousOptional = organizationRepository.findByName("anonymous");
        if (!anonymousOptional.isPresent()) {
            Organization anonymous = new Organization();
            anonymous.setName("anonymous");
            organizationRepository.save(anonymous);
        }

        // Ensure seed user exists with 'default' organization (configured via SEED_USERNAME / SEED_PASSWORD)
        if (!seedUsername.isEmpty() && !seedPassword.isEmpty() && !userRepository.findByUsername(seedUsername).isPresent()) {
            User user = new User();
            user.setUsername(seedUsername);
            user.setPassword(passwordEncoder.encode(seedPassword));
            user.setOrganization(defaultOrg);
            userRepository.save(user);
        }
    }
}