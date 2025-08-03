$(function() {
    let currentJobs = [];
    let jobHistory = [];
    let currentJobId = null;
    let currentJob = null;
    
    // Show job centre UI
    function showJobCentre() {
        $("#job-centre-container").fadeIn(300).css("display", "flex");
    }
    
    // Hide job centre UI
    function hideJobCentre() {
        $("#job-centre-container").fadeOut(300);
        setTimeout(() => {
            $.post('https://rs-jobcentre/closeJobCentre', JSON.stringify({}));
        }, 300);
    }
    
    // Format timestamp to readable date
    function formatTimestamp(timestamp) {
        const date = new Date(timestamp * 1000);
        const now = new Date();
        const diffDays = Math.floor((now - date) / (1000 * 60 * 60 * 24));
        
        if (diffDays === 0) {
            return "Today";
        } else if (diffDays === 1) {
            return "Yesterday";
        } else {
            return `${diffDays} days ago`;
        }
    }
    
    // Populate jobs list
    function populateJobsList(jobs) {
        const jobsList = $("#jobs-list");
        jobsList.empty();
        
        if (jobs.length === 0) {
            jobsList.html(`
                <div class="empty-state">
                    <i class="fas fa-briefcase"></i>
                    <p>No jobs available at the moment.</p>
                </div>
            `);
            return;
        }
        
        jobs.forEach(job => {
            const jobCard = $(`
                <div class="job-card" data-job-id="${job.id}">
                    <div class="job-icon">
                        <img src="img/${job.icon}" alt="${job.label}">
                    </div>
                    <h3 class="job-title">${job.label}</h3>
                    <p class="job-salary">${job.salary}</p>
                </div>
            `);
            
            jobsList.append(jobCard);
        });
    }
    
    // Populate job history
    function populateJobHistory(history) {
        const historyList = $("#history-list");
        historyList.empty();
        
        if (history.length === 0) {
            historyList.html(`
                <div class="empty-state">
                    <i class="fas fa-history"></i>
                    <p>No job history available.</p>
                </div>
            `);
            return;
        }
        
        history.forEach(item => {
            const historyItem = $(`
                <div class="history-item">
                    <div class="history-job-info">
                        <div class="history-job-icon">
                            <img src="img/${getJobIconById(item.jobId)}" alt="${item.jobName}">
                        </div>
                        <div class="history-job-details">
                            <h3>${item.jobName}</h3>
                            <p>Job ID: ${item.jobId}</p>
                        </div>
                    </div>
                    <div class="history-date">${formatTimestamp(item.timestamp)}</div>
                </div>
            `);
            
            historyList.append(historyItem);
        });
    }
    
    // Get job icon by ID
    function getJobIconById(jobId) {
        const job = currentJobs.find(j => j.id === jobId);
        return job ? job.icon : "default.png";
    }
    
    // Show job details modal
    function showJobDetails(jobId) {
        const job = currentJobs.find(j => j.id === jobId);
        if (!job) return;
        
        currentJobId = jobId;
        
        $("#modal-job-title").text(job.label);
        $("#modal-job-icon").attr("src", `img/${job.icon}`);
        $("#modal-job-description").text(job.description);
        $("#modal-job-salary").text(job.salary);
        $("#modal-job-requirements").text(job.requirements);
        
        $("#job-details-modal").fadeIn(200).css("display", "flex");
    }
    
    // Hide job details modal
    function hideJobDetails() {
        $("#job-details-modal").fadeOut(200);
        currentJobId = null;
    }
    
    // Filter jobs by search term
    function filterJobs(searchTerm) {
        if (!searchTerm) {
            populateJobsList(currentJobs);
            return;
        }
        
        const filteredJobs = currentJobs.filter(job => 
            job.label.toLowerCase().includes(searchTerm.toLowerCase()) || 
            job.description.toLowerCase().includes(searchTerm.toLowerCase())
        );
        
        populateJobsList(filteredJobs);
    }
    
    // Event listeners
    $("#close-button").on("click", hideJobCentre);
    
    $(document).on("keydown", function(e) {
        if (e.key === "Escape") {
            if ($("#job-details-modal").is(":visible")) {
                hideJobDetails();
            } else {
                hideJobCentre();
            }
        }
    });
    
    $(".tab").on("click", function() {
        const tabId = $(this).data("tab");
        
        $(".tab").removeClass("active");
        $(this).addClass("active");
        
        $(".tab-pane").removeClass("active");
        $(`#${tabId}`).addClass("active");
    });
    
    $(document).on("click", ".job-card", function() {
        const jobId = $(this).data("job-id");
        showJobDetails(jobId);
    });
    
    $("#close-modal").on("click", hideJobDetails);
    
    $("#apply-job-btn").on("click", function() {
        if (!currentJobId) return;
        
        $.post('https://rs-jobcentre/applyForJob', JSON.stringify({
            jobId: currentJobId
        }));
        
        hideJobDetails();
        hideJobCentre();
    });
    
    $("#set-waypoint-btn").on("click", function() {
        if (!currentJobId) return;
        
        $.post('https://rs-jobcentre/setWaypoint', JSON.stringify({
            jobId: currentJobId
        }));
        
        hideJobDetails();
        hideJobCentre();
    });
    
    $("#job-search").on("input", function() {
        const searchTerm = $(this).val().trim();
        filterJobs(searchTerm);
    });
    
    // NUI message handler
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === "openJobCentre") {
            currentJobs = data.jobs;
            jobHistory = data.history;
            currentJob = data.currentJob;
            
            populateJobsList(currentJobs);
            populateJobHistory(jobHistory);
            showJobCentre();
        }
    });
});