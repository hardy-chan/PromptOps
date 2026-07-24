class Api::V1::ProjectsController < ApplicationController
  def create
    # For testing, we find or create a dummy seed user
    user = User.find_or_create_by!(email: "applicant@example.com", token: "test_token_123")
    
    project = user.projects.create!(
      name: params[:name],
      language: params[:language],
      github_url: params[:github_url]
    )

    analysis = project.code_analyses.create!(status: "pending")

    # Enqueue the background worker instantly
    AnalyzeCodeJob.perform_later(analysis.id, params[:code_snippet])

    render json: { 
      message: "Analysis started successfully", 
      project_id: project.id, 
      analysis_id: analysis.id 
    }, status: :accepted
  end
end
